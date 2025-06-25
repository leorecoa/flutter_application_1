const DynamoDBService = require('../shared/dynamodb');
const ResponseHelper = require('../shared/response');
const AuthHelper = require('../shared/auth');
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event) => {
  console.log('Services Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  const user = AuthHelper.extractUserFromEvent(event);
  if (!user) {
    return ResponseHelper.unauthorized();
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const serviceId = pathParameters?.proxy;
    const requestBody = body ? JSON.parse(body) : {};

    switch (httpMethod) {
      case 'GET':
        return serviceId ? await getService(user.userId, serviceId) : await getServices(user.userId);
      
      case 'POST':
        return await createService(user.userId, requestBody);
      
      case 'PUT':
        return await updateService(user.userId, serviceId, requestBody);
      
      case 'DELETE':
        return await deleteService(user.userId, serviceId);
      
      default:
        return ResponseHelper.error('Method not allowed', 405);
    }
  } catch (error) {
    console.error('Services Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getServices(userId) {
  try {
    const services = await DynamoDBService.query(`USER#${userId}`, 'SERVICE#');
    return ResponseHelper.success(services);
  } catch (error) {
    console.error('Get services error:', error);
    return ResponseHelper.serverError('Failed to get services');
  }
}

async function getService(userId, serviceId) {
  try {
    const service = await DynamoDBService.getItem(`USER#${userId}`, `SERVICE#${serviceId}`);
    
    if (!service) {
      return ResponseHelper.notFound('Service not found');
    }

    return ResponseHelper.success(service);
  } catch (error) {
    console.error('Get service error:', error);
    return ResponseHelper.serverError('Failed to get service');
  }
}

async function createService(userId, body) {
  const { name, description, duration, price, category } = body;

  if (!name || !duration || !price) {
    return ResponseHelper.error('Name, duration, and price are required');
  }

  try {
    const serviceId = uuidv4();
    const service = {
      PK: `USER#${userId}`,
      SK: `SERVICE#${serviceId}`,
      serviceId,
      userId,
      name,
      description: description || '',
      duration: parseInt(duration),
      price: parseFloat(price),
      category: category || 'general',
      isActive: true,
      GSI1PK: `USER#${userId}`,
      GSI1SK: `SERVICE#${name.toLowerCase()}`
    };

    await DynamoDBService.putItem(service);
    return ResponseHelper.success(service, 201);

  } catch (error) {
    console.error('Create service error:', error);
    return ResponseHelper.serverError('Failed to create service');
  }
}

async function updateService(userId, serviceId, body) {
  if (!serviceId) {
    return ResponseHelper.error('Service ID is required');
  }

  try {
    const existingService = await DynamoDBService.getItem(`USER#${userId}`, `SERVICE#${serviceId}`);
    
    if (!existingService) {
      return ResponseHelper.notFound('Service not found');
    }

    const { name, description, duration, price, category, isActive } = body;
    
    let updateExpression = 'SET updatedAt = :updatedAt';
    const expressionAttributeValues = {
      ':updatedAt': new Date().toISOString()
    };

    if (name !== undefined) {
      updateExpression += ', #name = :name';
      expressionAttributeValues[':name'] = name;
    }

    if (description !== undefined) {
      updateExpression += ', description = :description';
      expressionAttributeValues[':description'] = description;
    }

    if (duration !== undefined) {
      updateExpression += ', duration = :duration';
      expressionAttributeValues[':duration'] = parseInt(duration);
    }

    if (price !== undefined) {
      updateExpression += ', price = :price';
      expressionAttributeValues[':price'] = parseFloat(price);
    }

    if (category !== undefined) {
      updateExpression += ', category = :category';
      expressionAttributeValues[':category'] = category;
    }

    if (isActive !== undefined) {
      updateExpression += ', isActive = :isActive';
      expressionAttributeValues[':isActive'] = isActive;
    }

    const expressionAttributeNames = name !== undefined ? { '#name': 'name' } : {};

    const updatedService = await DynamoDBService.updateItem(
      `USER#${userId}`,
      `SERVICE#${serviceId}`,
      updateExpression,
      expressionAttributeValues,
      expressionAttributeNames
    );

    return ResponseHelper.success(updatedService);

  } catch (error) {
    console.error('Update service error:', error);
    return ResponseHelper.serverError('Failed to update service');
  }
}

async function deleteService(userId, serviceId) {
  if (!serviceId) {
    return ResponseHelper.error('Service ID is required');
  }

  try {
    const existingService = await DynamoDBService.getItem(`USER#${userId}`, `SERVICE#${serviceId}`);
    
    if (!existingService) {
      return ResponseHelper.notFound('Service not found');
    }

    await DynamoDBService.deleteItem(`USER#${userId}`, `SERVICE#${serviceId}`);
    return ResponseHelper.success({ message: 'Service deleted successfully' });

  } catch (error) {
    console.error('Delete service error:', error);
    return ResponseHelper.serverError('Failed to delete service');
  }
}