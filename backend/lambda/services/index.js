const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('ServicesFunction Event:', JSON.stringify(event, null, 2));

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
        return await createService(requestBody, tenantId);
      case 'GET:':
        return await listServices(tenantId);
      case 'PUT:':
        return await updateService(requestBody, tenantId);
      case 'DELETE:':
        return await deleteService(requestBody.serviceId, tenantId);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'services' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('ServicesFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function createService(body, tenantId) {
  const { name, price, duration, description } = body;

  if (!name || !price || !duration) {
    return ResponseHelper.error('Missing required fields: name, price, duration');
  }

  const serviceId = `service_${Date.now()}`;
  const service = {
    PK: `TENANT#${tenantId}`,
    SK: `SERVICE#${serviceId}`,
    serviceId,
    name,
    price: parseFloat(price),
    duration: parseInt(duration),
    description: description || '',
    isActive: true,
    createdAt: new Date().toISOString()
  };

  const params = {
    TableName: process.env.MAIN_TABLE,
    Item: service
  };

  await dynamodb.put(params).promise();
  return ResponseHelper.success(service, 201);
}

async function listServices(tenantId) {
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'SERVICE#'
    }
  };

  const result = await dynamodb.query(params).promise();
  return ResponseHelper.success(result.Items);
}

async function updateService(body, tenantId) {
  const { serviceId, name, price, duration, description, isActive } = body;

  if (!serviceId) {
    return ResponseHelper.error('serviceId is required');
  }

  const updateExpression = [];
  const expressionValues = {};
  
  if (name) {
    updateExpression.push('name = :name');
    expressionValues[':name'] = name;
  }
  if (price) {
    updateExpression.push('price = :price');
    expressionValues[':price'] = parseFloat(price);
  }
  if (duration) {
    updateExpression.push('duration = :duration');
    expressionValues[':duration'] = parseInt(duration);
  }
  if (description !== undefined) {
    updateExpression.push('description = :description');
    expressionValues[':description'] = description;
  }
  if (isActive !== undefined) {
    updateExpression.push('isActive = :isActive');
    expressionValues[':isActive'] = isActive;
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `SERVICE#${serviceId}`
    },
    UpdateExpression: `SET ${updateExpression.join(', ')}`,
    ExpressionAttributeValues: expressionValues,
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return ResponseHelper.success(result.Attributes);
}

async function deleteService(serviceId, tenantId) {
  if (!serviceId) {
    return ResponseHelper.error('serviceId is required');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `SERVICE#${serviceId}`
    }
  };

  await dynamodb.delete(params).promise();
  return ResponseHelper.success({ message: 'Service deleted successfully' });
}