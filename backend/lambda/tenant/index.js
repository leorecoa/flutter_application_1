const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('TenantFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body, requestContext } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};
    
    // Extract user from Cognito
    const userId = requestContext?.authorizer?.claims?.sub;
    if (!userId) {
      return ResponseHelper.unauthorized('User not authenticated');
    }

    switch (`${httpMethod}:${path}`) {
      case 'POST:':
        return await createTenant(requestBody, userId);
      case 'GET:':
        return await listTenants(userId);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'tenant' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('TenantFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function createTenant(body, userId) {
  const { businessName, businessType, email, phone } = body;

  if (!businessName || !businessType || !email) {
    return ResponseHelper.error('Missing required fields: businessName, businessType, email');
  }

  const tenantId = `tenant_${Date.now()}`;
  const tenant = {
    PK: `TENANT#${tenantId}`,
    SK: 'PROFILE',
    tenantId,
    businessName,
    businessType,
    email,
    phone,
    ownerId: userId,
    createdAt: new Date().toISOString(),
    isActive: true
  };

  const params = {
    TableName: process.env.MAIN_TABLE,
    Item: tenant
  };

  await dynamodb.put(params).promise();
  return ResponseHelper.success(tenant, 201);
}

async function listTenants(userId) {
  const params = {
    TableName: process.env.MAIN_TABLE,
    FilterExpression: 'ownerId = :userId AND begins_with(PK, :pk)',
    ExpressionAttributeValues: {
      ':userId': userId,
      ':pk': 'TENANT#'
    }
  };

  const result = await dynamodb.scan(params).promise();
  return ResponseHelper.success(result.Items);
}