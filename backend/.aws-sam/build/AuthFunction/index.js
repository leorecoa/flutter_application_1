const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('AuthFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};

    switch (`${httpMethod}:${path}`) {
      case 'POST:register':
        return await handleRegister(requestBody);
      case 'POST:login':
        return await handleLogin(requestBody);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'auth' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('AuthFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function handleRegister(body) {
  const { email, password, name, businessName, businessType } = body;

  if (!email || !password || !name || !businessName || !businessType) {
    return ResponseHelper.error('Missing required fields: email, password, name, businessName, businessType');
  }

  try {
    const userId = `user_${Date.now()}`;
    const tenantId = `tenant_${Date.now()}`;
    
    const tenant = {
      PK: `TENANT#${tenantId}`,
      SK: 'PROFILE',
      tenantId,
      businessName,
      businessType,
      email,
      ownerId: userId,
      createdAt: new Date().toISOString(),
      isActive: true
    };

    const userProfile = {
      PK: `TENANT#${tenantId}`,
      SK: `USER#${userId}`,
      userId,
      email,
      name,
      role: 'admin',
      tenantId,
      createdAt: new Date().toISOString(),
      isActive: true
    };

    await Promise.all([
      dynamodb.put({
        TableName: process.env.MAIN_TABLE,
        Item: tenant
      }).promise(),
      dynamodb.put({
        TableName: process.env.MAIN_TABLE,
        Item: userProfile
      }).promise()
    ]);

    return ResponseHelper.success({
      user: { ...userProfile, tenantId },
      tenant,
      message: 'Registration successful'
    }, 201);

  } catch (error) {
    console.error('Registration error:', error);
    return ResponseHelper.serverError('Registration failed');
  }
}

async function handleLogin(body) {
  const { email, password } = body;

  if (!email || !password) {
    return ResponseHelper.error('Email and password are required');
  }

  // Simplified login - in production use proper authentication
  return ResponseHelper.success({
    token: 'mock-jwt-token',
    user: { email, name: 'Test User' },
    message: 'Login successful'
  });
}