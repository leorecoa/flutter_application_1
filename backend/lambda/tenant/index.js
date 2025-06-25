const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const MultiTenantMiddleware = require('../shared/multi-tenant');
const ResponseHelper = require('../shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const cognito = new AWS.CognitoIdentityServiceProvider();
const s3 = new AWS.S3();

const handler = async (event) => {
  const { httpMethod, pathParameters, body } = event;
  const path = pathParameters?.proxy || '';
  const requestBody = body ? JSON.parse(body) : {};

  switch (`${httpMethod}:${path}`) {
    case 'POST:create':
      return await createTenant(event, requestBody);
    
    case 'GET:config':
      return await getTenantConfig(event);
    
    case 'PUT:config':
      return await updateTenantConfig(event, requestBody);
    
    case 'POST:upload-logo':
      return await uploadLogo(event, requestBody);
    
    default:
      return ResponseHelper.notFound('Endpoint not found');
  }
};

async function createTenant(event, body) {
  const { name, businessType } = body;
  const { userId, email } = event.tenant;

  if (!name || !businessType) {
    return ResponseHelper.error('Missing required fields: name, businessType');
  }

  try {
    const tenantId = uuidv4();
    const now = new Date().toISOString();

    // Create tenant record
    const tenantRecord = {
      PK: `TENANT#${tenantId}`,
      SK: 'CONFIG',
      tenantId,
      name,
      businessType,
      createdAt: now,
      isActive: true,
      theme: {
        primaryColor: '#007bff',
        logoUrl: null
      },
      settings: {
        workingHours: {
          monday: { start: '09:00', end: '18:00', enabled: true },
          tuesday: { start: '09:00', end: '18:00', enabled: true },
          wednesday: { start: '09:00', end: '18:00', enabled: true },
          thursday: { start: '09:00', end: '18:00', enabled: true },
          friday: { start: '09:00', end: '18:00', enabled: true },
          saturday: { start: '09:00', end: '14:00', enabled: true },
          sunday: { start: '09:00', end: '14:00', enabled: false }
        }
      }
    };

    // Create user-tenant association
    const userTenantRecord = {
      PK: `TENANT#${tenantId}`,
      SK: `USER#${userId}`,
      userId,
      email,
      role: 'admin',
      joinedAt: now,
      GSI1PK: `USER#${userId}`,
      GSI1SK: `TENANT#${tenantId}`
    };

    // Batch write
    await dynamodb.batchWrite({
      RequestItems: {
        [process.env.MAIN_TABLE]: [
          { PutRequest: { Item: tenantRecord } },
          { PutRequest: { Item: userTenantRecord } }
        ]
      }
    }).promise();

    // Update user's Cognito attributes
    await cognito.adminUpdateUserAttributes({
      UserPoolId: process.env.COGNITO_USER_POOL_ID,
      Username: userId,
      UserAttributes: [
        { Name: 'custom:tenantId', Value: tenantId },
        { Name: 'custom:plan', Value: 'free' }
      ]
    }).promise();

    return ResponseHelper.success({
      tenant: tenantRecord,
      message: 'Tenant created successfully'
    });

  } catch (error) {
    console.error('Create tenant error:', error);
    return ResponseHelper.serverError('Failed to create tenant');
  }
}

async function getTenantConfig(event) {
  const { id: tenantId } = event.tenant;

  if (!tenantId) {
    return ResponseHelper.error('Tenant ID required');
  }

  try {
    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: 'CONFIG'
      }
    };

    const result = await dynamodb.get(params).promise();
    
    if (!result.Item) {
      return ResponseHelper.notFound('Tenant not found');
    }

    return ResponseHelper.success(result.Item);

  } catch (error) {
    console.error('Get tenant config error:', error);
    return ResponseHelper.serverError('Failed to get tenant config');
  }
}

async function updateTenantConfig(event, body) {
  const { id: tenantId } = event.tenant;
  const { name, theme, settings } = body;

  if (!tenantId) {
    return ResponseHelper.error('Tenant ID required');
  }

  try {
    const updateExpression = [];
    const expressionAttributeValues = {};
    const expressionAttributeNames = {};

    if (name) {
      updateExpression.push('#name = :name');
      expressionAttributeNames['#name'] = 'name';
      expressionAttributeValues[':name'] = name;
    }

    if (theme) {
      updateExpression.push('#theme = :theme');
      expressionAttributeNames['#theme'] = 'theme';
      expressionAttributeValues[':theme'] = theme;
    }

    if (settings) {
      updateExpression.push('#settings = :settings');
      expressionAttributeNames['#settings'] = 'settings';
      expressionAttributeValues[':settings'] = settings;
    }

    updateExpression.push('updatedAt = :updatedAt');
    expressionAttributeValues[':updatedAt'] = new Date().toISOString();

    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: 'CONFIG'
      },
      UpdateExpression: `SET ${updateExpression.join(', ')}`,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW'
    };

    const result = await dynamodb.update(params).promise();

    return ResponseHelper.success({
      tenant: result.Attributes,
      message: 'Tenant updated successfully'
    });

  } catch (error) {
    console.error('Update tenant config error:', error);
    return ResponseHelper.serverError('Failed to update tenant config');
  }
}

async function uploadLogo(event, body) {
  const { id: tenantId } = event.tenant;
  const { fileName, fileType, fileContent } = body;

  if (!tenantId || !fileName || !fileContent) {
    return ResponseHelper.error('Missing required fields');
  }

  try {
    const key = `tenants/${tenantId}/logo/${fileName}`;
    const buffer = Buffer.from(fileContent, 'base64');

    // Upload to S3
    await s3.putObject({
      Bucket: process.env.S3_BUCKET,
      Key: key,
      Body: buffer,
      ContentType: fileType || 'image/png',
      ACL: 'private'
    }).promise();

    // Generate presigned URL
    const logoUrl = s3.getSignedUrl('getObject', {
      Bucket: process.env.S3_BUCKET,
      Key: key,
      Expires: 3600 * 24 * 7 // 7 days
    });

    // Update tenant config with logo URL
    await dynamodb.update({
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: 'CONFIG'
      },
      UpdateExpression: 'SET theme.logoUrl = :logoUrl, updatedAt = :updatedAt',
      ExpressionAttributeValues: {
        ':logoUrl': logoUrl,
        ':updatedAt': new Date().toISOString()
      }
    }).promise();

    return ResponseHelper.success({
      logoUrl,
      message: 'Logo uploaded successfully'
    });

  } catch (error) {
    console.error('Upload logo error:', error);
    return ResponseHelper.serverError('Failed to upload logo');
  }
}

exports.handler = MultiTenantMiddleware.withMultiTenant(handler);