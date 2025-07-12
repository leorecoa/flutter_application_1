const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.SERVICES_TABLE || 'agendemais-services';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ message: 'OK' })
    };
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const serviceId = pathParameters?.id;

    switch (httpMethod) {
      case 'GET':
        return await getServices(event);
      case 'POST':
        if (serviceId && pathParameters.action === 'delete') {
          return await deleteService(serviceId);
        }
        return await createService(JSON.parse(body));
      case 'PUT':
        return await updateService(serviceId, JSON.parse(body));
      default:
        return {
          statusCode: 405,
          headers: corsHeaders,
          body: JSON.stringify({ success: false, message: 'Method not allowed' })
        };
    }
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ 
        success: false, 
        message: 'Internal server error',
        error: error.message 
      })
    };
  }
};

async function getServices(event) {
  const { queryStringParameters } = event;
  const category = queryStringParameters?.category;

  let params = {
    TableName: TABLE_NAME
  };

  if (category && category !== 'Todos') {
    params.FilterExpression = 'category = :category';
    params.ExpressionAttributeValues = {
      ':category': category
    };
  }

  const result = await dynamodb.scan(params).promise();
  
  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      data: result.Items || []
    })
  };
}

async function createService(serviceData) {
  const now = new Date().toISOString();
  const service = {
    id: uuidv4(),
    name: serviceData.name,
    description: serviceData.description || '',
    price: serviceData.price,
    durationMinutes: serviceData.durationMinutes || 60,
    category: serviceData.category || 'Geral',
    isActive: serviceData.isActive !== false,
    createdAt: now,
    updatedAt: now
  };

  await dynamodb.put({
    TableName: TABLE_NAME,
    Item: service
  }).promise();

  return {
    statusCode: 201,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      data: service,
      message: 'Serviço criado com sucesso'
    })
  };
}

async function updateService(serviceId, serviceData) {
  const now = new Date().toISOString();
  
  const params = {
    TableName: TABLE_NAME,
    Key: { id: serviceId },
    UpdateExpression: 'SET #name = :name, description = :description, price = :price, durationMinutes = :duration, category = :category, isActive = :isActive, updatedAt = :updatedAt',
    ExpressionAttributeNames: {
      '#name': 'name'
    },
    ExpressionAttributeValues: {
      ':name': serviceData.name,
      ':description': serviceData.description || '',
      ':price': serviceData.price,
      ':duration': serviceData.durationMinutes || 60,
      ':category': serviceData.category || 'Geral',
      ':isActive': serviceData.isActive !== false,
      ':updatedAt': now
    },
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      data: result.Attributes,
      message: 'Serviço atualizado com sucesso'
    })
  };
}

async function deleteService(serviceId) {
  await dynamodb.delete({
    TableName: TABLE_NAME,
    Key: { id: serviceId }
  }).promise();

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      message: 'Serviço excluído com sucesso'
    })
  };
}