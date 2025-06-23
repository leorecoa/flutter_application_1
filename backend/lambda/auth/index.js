const DynamoDBService = require('../shared/dynamodb');
const ResponseHelper = require('../shared/response');
const AuthHelper = require('../shared/auth');

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
      case 'POST:register':
        return await handleRegister(requestBody);
      
      case 'POST:login':
        return await handleLogin(requestBody);
      
      case 'POST:refresh':
        return await handleRefreshToken(requestBody);
      
      case 'GET:me':
        return await handleGetProfile(event);
      
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    console.error('Auth Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function handleRegister(body) {
  const { email, password, name, phone, businessName, businessType } = body;

  if (!email || !password || !name || !businessName || !businessType) {
    return ResponseHelper.error('Missing required fields');
  }

  try {
    // Create user in Cognito
    const cognitoUser = await AuthHelper.createCognitoUser(email, password, name, phone);
    const userId = cognitoUser.Username;

    // Create user profile in DynamoDB
    const userProfile = {
      PK: `USER#${userId}`,
      SK: 'PROFILE',
      userId,
      email,
      name,
      phone: phone || '',
      businessName,
      businessType,
      customLink: businessName.toLowerCase().replace(/[^a-z0-9]/g, '-'),
      planId: 'free',
      planExpiry: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days
      isActive: true,
      settings: {
        whatsappEnabled: false,
        whatsappNumber: phone || '',
        paymentMethods: ['cash'],
        workingHours: {
          monday: { start: '09:00', end: '18:00', enabled: true },
          tuesday: { start: '09:00', end: '18:00', enabled: true },
          wednesday: { start: '09:00', end: '18:00', enabled: true },
          thursday: { start: '09:00', end: '18:00', enabled: true },
          friday: { start: '09:00', end: '18:00', enabled: true },
          saturday: { start: '09:00', end: '14:00', enabled: true },
          sunday: { start: '09:00', end: '14:00', enabled: false }
        }
      },
      GSI1PK: `LINK#${businessName.toLowerCase().replace(/[^a-z0-9]/g, '-')}`,
      GSI1SK: `USER#${userId}`
    };

    await DynamoDBService.putItem(userProfile);

    // Authenticate user to get tokens
    const authResult = await AuthHelper.authenticateUser(email, password);

    return ResponseHelper.success({
      user: userProfile,
      tokens: authResult
    });

  } catch (error) {
    console.error('Registration error:', error);
    if (error.code === 'UsernameExistsException') {
      return ResponseHelper.error('User already exists');
    }
    return ResponseHelper.serverError('Registration failed');
  }
}

async function handleLogin(body) {
  const { email, password } = body;

  if (!email || !password) {
    return ResponseHelper.error('Email and password are required');
  }

  try {
    // Authenticate with Cognito
    const authResult = await AuthHelper.authenticateUser(email, password);
    
    // Get user profile from DynamoDB
    const userProfile = await DynamoDBService.query(`USER#${authResult.IdToken}`, 'PROFILE');
    
    return ResponseHelper.success({
      user: userProfile[0],
      tokens: authResult
    });

  } catch (error) {
    console.error('Login error:', error);
    if (error.code === 'NotAuthorizedException') {
      return ResponseHelper.unauthorized('Invalid credentials');
    }
    return ResponseHelper.serverError('Login failed');
  }
}

async function handleRefreshToken(body) {
  const { refreshToken } = body;

  if (!refreshToken) {
    return ResponseHelper.error('Refresh token is required');
  }

  try {
    const params = {
      AuthFlow: 'REFRESH_TOKEN_AUTH',
      UserPoolId: process.env.COGNITO_USER_POOL_ID,
      ClientId: process.env.COGNITO_CLIENT_ID,
      AuthParameters: {
        REFRESH_TOKEN: refreshToken
      }
    };

    const cognito = new AWS.CognitoIdentityServiceProvider();
    const result = await cognito.adminInitiateAuth(params).promise();

    return ResponseHelper.success({
      tokens: result.AuthenticationResult
    });

  } catch (error) {
    console.error('Refresh token error:', error);
    return ResponseHelper.unauthorized('Invalid refresh token');
  }
}

async function handleGetProfile(event) {
  const user = AuthHelper.extractUserFromEvent(event);
  
  if (!user) {
    return ResponseHelper.unauthorized();
  }

  try {
    const userProfile = await DynamoDBService.getItem(`USER#${user.userId}`, 'PROFILE');
    
    if (!userProfile) {
      return ResponseHelper.notFound('User profile not found');
    }

    return ResponseHelper.success(userProfile);

  } catch (error) {
    console.error('Get profile error:', error);
    return ResponseHelper.serverError('Failed to get profile');
  }
}