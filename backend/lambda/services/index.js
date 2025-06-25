const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const MultiTenantMiddleware = require('../shared/multi-tenant');
const ResponseHelper = require('../shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

const handler = async (event) => {
  const { httpMethod, pathParameters, body } = event;
  const path = pathParameters?.proxy || '';
  const requestBody = body ? JSON.parse(body) : {};

  switch (`${httpMethod}:${path}`) {
    case 'GET:':
      return await getServices(event);
    
    case 'POST:':
      return await createService(event, requestBody);
    
    case 'PUT:':
      return await updateService(event, requestBody);
    
    case 'DELETE:':
      return await deleteService(event, requestBody);
    
    default:
      return ResponseHelper.notFound('Endpoint not found');
  }
};

async function getServices(event) {
  const { id: tenantId } = event.tenant;

  try {
    const params = {
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#SERVICES`,
        ':sk': 'SERVICE#'
      }
    };

    const result = await dynamodb.query(params).promise();

    return ResponseHelper.success({
      data: result.Items,
      count: result.Items.length
    });

  } catch (error) {
    console.error('Get services error:', error);
    return ResponseHelper.serverError('Failed to get services');
  }
}

async function createService(event, body) {
  const { id: tenantId, plan } = event.tenant;
  const { name, price, duration, description } = body;

  if (!name || !price || !duration) {
    return ResponseHelper.error('Missing required fields: name, price, duration');
  }

  try {
    // Check quota for free plan
    const quota = await MultiTenantMiddleware.checkQuota(tenantId, plan, 'services');
    if (!quota.allowed) {
      return ResponseHelper.error(`Service limit reached. Current: ${quota.current}/${quota.limit}`);
    }

    const serviceId = uuidv4();
    const now = new Date().toISOString();

    const service = {
      PK: `TENANT#${tenantId}#SERVICES`,
      SK: `SERVICE#${serviceId}`,
      serviceId,
      tenantId,
      name,
      price: parseFloat(price),
      duration: parseInt(duration),
      description: description || '',
      isActive: true,
      createdAt: now,
      updatedAt: now,
      GSI1PK: `TENANT#${tenantId}#SERVICES`,
      GSI1SK: `ACTIVE#${serviceId}`
    };

    await dynamodb.put({
      TableName: process.env.MAIN_TABLE,
      Item: service
    }).promise();

    return ResponseHelper.success({
      data: service,
      message: 'Service created successfully'
    });

  } catch (error) {
    console.error('Create service error:', error);
    return ResponseHelper.serverError('Failed to create service');
  }
}

async function updateService(event, body) {
  const { id: tenantId } = event.tenant;
  const { serviceId, name, price, duration, description } = body;

  if (!serviceId) {
    return ResponseHelper.error('Service ID required');
  }

  try {
    const updateExpression = [];
    const expressionAttributeValues = {};

    if (name) {
      updateExpression.push('name = :name');
      expressionAttributeValues[':name'] = name;
    }
    if (price !== undefined) {
      updateExpression.push('price = :price');
      expressionAttributeValues[':price'] = parseFloat(price);
    }
    if (duration !== undefined) {
      updateExpression.push('duration = :duration');
      expressionAttributeValues[':duration'] = parseInt(duration);
    }
    if (description !== undefined) {
      updateExpression.push('description = :description');
      expressionAttributeValues[':description'] = description;
    }

    updateExpression.push('updatedAt = :updatedAt');
    expressionAttributeValues[':updatedAt'] = new Date().toISOString();

    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}#SERVICES`,
        SK: `SERVICE#${serviceId}`
      },
      UpdateExpression: `SET ${updateExpression.join(', ')}`,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW'
    };

    const result = await dynamodb.update(params).promise();

    return ResponseHelper.success({
      data: result.Attributes,
      message: 'Service updated successfully'
    });

  } catch (error) {
    console.error('Update service error:', error);
    return ResponseHelper.serverError('Failed to update service');
  }
}

async function deleteService(event, body) {
  const { id: tenantId } = event.tenant;
  const { serviceId } = body;

  if (!serviceId) {
    return ResponseHelper.error('Service ID required');
  }

  try {
    await dynamodb.delete({
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}#SERVICES`,
        SK: `SERVICE#${serviceId}`
      }
    }).promise();

    return ResponseHelper.success({
      message: 'Service deleted successfully'
    });

  } catch (error) {
    console.error('Delete service error:', error);
    return ResponseHelper.serverError('Failed to delete service');
  }
}

exports.handler = MultiTenantMiddleware.withMultiTenant(handler);