const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log('Auth Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};

    switch (`${httpMethod}:${path}`) {
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', timestamp: new Date().toISOString() });
      
      case 'POST:register':
        return await handleRegister(requestBody);
      
      case 'POST:login':
        return await handleLogin(requestBody);
      
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    console.error('Auth Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function handleRegister(body) {
  const { email, password, name, businessName, businessType } = body;

  if (!email || !password || !name || !businessName || !businessType) {
    return ResponseHelper.error('Missing required fields');
  }

  try {
    // Simplified user creation - just save to DynamoDB
    const userId = `user_${Date.now()}`;
    const userProfile = {
      PK: `USER#${userId}`,
      SK: 'PROFILE',
      userId,
      email,
      name,
      businessName,
      businessType,
      createdAt: new Date().toISOString(),
      isActive: true
    };

    const params = {
      TableName: process.env.USERS_TABLE || 'agenda-facil-dev-users',
      Item: userProfile
    };

    await dynamodb.put(params).promise();

    return ResponseHelper.success({
      user: userProfile,
      message: 'User registered successfully'
    });

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

  try {
    // Simplified login - just return success for now
    return ResponseHelper.success({
      user: { email, name: 'Test User' },
      token: 'fake-jwt-token',
      message: 'Login successful'
    });

  } catch (error) {
    console.error('Login error:', error);
    return ResponseHelper.serverError('Login failed');
  }
}