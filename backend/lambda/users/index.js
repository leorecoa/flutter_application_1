const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('UsersFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body, requestContext } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};
    
    const userId = requestContext?.authorizer?.claims?.sub;
    const tenantId = requestContext?.authorizer?.claims?.['custom:tenantId'];
    
    if (!userId || !tenantId) {
      return ResponseHelper.unauthorized('User not authenticated or tenant not found');
    }

    switch (`${httpMethod}:${path}`) {
      case 'POST:':
        return await createUser(requestBody, tenantId);
      case 'GET:':
        return await listUsers(tenantId);
      case 'PUT:':
        return await updateUser(requestBody, tenantId);
      case 'DELETE:':
        return await deactivateUser(requestBody.userId, tenantId);
      case 'GET:profile':
        return await getUserProfile(userId, tenantId);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'users' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('UsersFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function createUser(body, tenantId) {
  const { name, email, phone, role, permissions } = body;

  if (!name || !email || !role) {
    return ResponseHelper.error('Missing required fields: name, email, role');
  }

  const userId = `user_${Date.now()}`;
  const user = {
    PK: `TENANT#${tenantId}`,
    SK: `USER#${userId}`,
    userId,
    name,
    email,
    phone: phone || '',
    role, // 'admin', 'staff', 'viewer'
    permissions: permissions || [],
    isActive: true,
    createdAt: new Date().toISOString()
  };

  const params = {
    TableName: process.env.MAIN_TABLE,
    Item: user
  };

  await dynamodb.put(params).promise();
  return ResponseHelper.success(user, 201);
}

async function listUsers(tenantId) {
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'USER#'
    }
  };

  const result = await dynamodb.query(params).promise();
  return ResponseHelper.success(result.Items);
}

async function updateUser(body, tenantId) {
  const { userId, name, email, phone, role, permissions, isActive } = body;

  if (!userId) {
    return ResponseHelper.error('userId is required');
  }

  const updateExpression = [];
  const expressionValues = {};
  
  if (name) {
    updateExpression.push('name = :name');
    expressionValues[':name'] = name;
  }
  if (email) {
    updateExpression.push('email = :email');
    expressionValues[':email'] = email;
  }
  if (phone !== undefined) {
    updateExpression.push('phone = :phone');
    expressionValues[':phone'] = phone;
  }
  if (role) {
    updateExpression.push('#role = :role');
    expressionValues[':role'] = role;
  }
  if (permissions) {
    updateExpression.push('permissions = :permissions');
    expressionValues[':permissions'] = permissions;
  }
  if (isActive !== undefined) {
    updateExpression.push('isActive = :isActive');
    expressionValues[':isActive'] = isActive;
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `USER#${userId}`
    },
    UpdateExpression: `SET ${updateExpression.join(', ')}`,
    ExpressionAttributeValues: expressionValues,
    ExpressionAttributeNames: role ? { '#role': 'role' } : undefined,
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return ResponseHelper.success(result.Attributes);
}

async function deactivateUser(userId, tenantId) {
  if (!userId) {
    return ResponseHelper.error('userId is required');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `USER#${userId}`
    },
    UpdateExpression: 'SET isActive = :isActive',
    ExpressionAttributeValues: { ':isActive': false },
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return ResponseHelper.success(result.Attributes);
}

async function getUserProfile(cognitoUserId, tenantId) {
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'cognitoUserId = :cognitoUserId',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'USER#',
      ':cognitoUserId': cognitoUserId
    }
  };

  const result = await dynamodb.query(params).promise();
  
  if (result.Items.length === 0) {
    return ResponseHelper.notFound('User profile not found');
  }
  
  return ResponseHelper.success(result.Items[0]);
}