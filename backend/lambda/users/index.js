const DynamoDBService = require('../shared/dynamodb');
const ResponseHelper = require('../shared/response');
const AuthHelper = require('../shared/auth');

exports.handler = async (event) => {
  console.log('Users Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  const user = AuthHelper.extractUserFromEvent(event);
  if (!user) {
    return ResponseHelper.unauthorized();
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const requestBody = body ? JSON.parse(body) : {};

    switch (httpMethod) {
      case 'GET':
        return await getUserProfile(user.userId);
      
      case 'PUT':
        return await updateUserProfile(user.userId, requestBody);
      
      default:
        return ResponseHelper.error('Method not allowed', 405);
    }
  } catch (error) {
    console.error('Users Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getUserProfile(userId) {
  try {
    const userProfile = await DynamoDBService.getItem(`USER#${userId}`, 'PROFILE');
    
    if (!userProfile) {
      return ResponseHelper.notFound('User profile not found');
    }

    return ResponseHelper.success(userProfile);
  } catch (error) {
    console.error('Get user profile error:', error);
    return ResponseHelper.serverError('Failed to get user profile');
  }
}

async function updateUserProfile(userId, updates) {
  try {
    const existingProfile = await DynamoDBService.getItem(`USER#${userId}`, 'PROFILE');
    
    if (!existingProfile) {
      return ResponseHelper.notFound('User profile not found');
    }

    const { name, phone, businessName, settings } = updates;
    
    let updateExpression = 'SET updatedAt = :updatedAt';
    const expressionAttributeValues = {
      ':updatedAt': new Date().toISOString()
    };

    if (name !== undefined) {
      updateExpression += ', #name = :name';
      expressionAttributeValues[':name'] = name;
    }

    if (phone !== undefined) {
      updateExpression += ', phone = :phone';
      expressionAttributeValues[':phone'] = phone;
    }

    if (businessName !== undefined) {
      updateExpression += ', businessName = :businessName';
      expressionAttributeValues[':businessName'] = businessName;
    }

    if (settings !== undefined) {
      updateExpression += ', settings = :settings';
      expressionAttributeValues[':settings'] = settings;
    }

    const expressionAttributeNames = name !== undefined ? { '#name': 'name' } : {};

    const updatedProfile = await DynamoDBService.updateItem(
      `USER#${userId}`,
      'PROFILE',
      updateExpression,
      expressionAttributeValues,
      expressionAttributeNames
    );

    return ResponseHelper.success(updatedProfile);
  } catch (error) {
    console.error('Update user profile error:', error);
    return ResponseHelper.serverError('Failed to update user profile');
  }
}