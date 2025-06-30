const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const MAIN_TABLE = process.env.MAIN_TABLE;

const PLANS = {
  FREE: {
    name: 'FREE',
    price: 0,
    limits: {
      clients: 5,
      barbers: 1,
      appointments: 50
    }
  },
  PRO: {
    name: 'PRO',
    price: 29.90,
    limits: {
      clients: 500,
      barbers: 5,
      appointments: 1000
    }
  },
  PREMIUM: {
    name: 'PREMIUM',
    price: 59.90,
    limits: {
      clients: -1,
      barbers: -1,
      appointments: -1
    }
  }
};

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers };
  }

  try {
    const tenantId = event.requestContext?.authorizer?.claims?.['custom:tenantId'] || 'default-tenant';
    const { httpMethod } = event;
    const body = event.body ? JSON.parse(event.body) : {};

    switch (httpMethod) {
      case 'POST':
        return await createSubscription(tenantId, body, headers);
      case 'GET':
        return await getSubscription(tenantId, headers);
      case 'PUT':
        return await updateSubscription(tenantId, body, headers);
      default:
        return {
          statusCode: 405,
          headers,
          body: JSON.stringify({ error: 'Method not allowed' })
        };
    }
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};

async function createSubscription(tenantId, body, headers) {
  const { plan = 'FREE' } = body;
  
  if (!PLANS[plan]) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ error: 'Invalid plan' })
    };
  }

  const now = new Date();
  const subscription = {
    PK: `TENANT#${tenantId}`,
    SK: 'SUBSCRIPTION',
    plan,
    status: 'ACTIVE',
    limits: PLANS[plan].limits,
    price: PLANS[plan].price,
    startDate: now.toISOString(),
    expirationDate: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
    // TODO: Add payment integration fields
    paymentProvider: null,
    paymentId: null,
    paymentStatus: 'PENDING'
  };

  await dynamodb.put({
    TableName: MAIN_TABLE,
    Item: subscription
  }).promise();

  return {
    statusCode: 201,
    headers,
    body: JSON.stringify(subscription)
  };
}

async function getSubscription(tenantId, headers) {
  const result = await dynamodb.get({
    TableName: MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: 'SUBSCRIPTION'
    }
  }).promise();

  if (!result.Item) {
    return await createSubscription(tenantId, { plan: 'FREE' }, headers);
  }

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify(result.Item)
  };
}

async function updateSubscription(tenantId, body, headers) {
  const { plan, status } = body;
  
  if (plan && !PLANS[plan]) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ error: 'Invalid plan' })
    };
  }

  const updateExpression = [];
  const expressionAttributeValues = {};
  const expressionAttributeNames = {};

  if (plan) {
    updateExpression.push('#plan = :plan');
    updateExpression.push('#limits = :limits');
    updateExpression.push('#price = :price');
    expressionAttributeNames['#plan'] = 'plan';
    expressionAttributeNames['#limits'] = 'limits';
    expressionAttributeNames['#price'] = 'price';
    expressionAttributeValues[':plan'] = plan;
    expressionAttributeValues[':limits'] = PLANS[plan].limits;
    expressionAttributeValues[':price'] = PLANS[plan].price;
  }

  if (status) {
    updateExpression.push('#status = :status');
    expressionAttributeNames['#status'] = 'status';
    expressionAttributeValues[':status'] = status;
  }

  updateExpression.push('#updatedAt = :updatedAt');
  expressionAttributeNames['#updatedAt'] = 'updatedAt';
  expressionAttributeValues[':updatedAt'] = new Date().toISOString();

  // TODO: Add payment processing logic here
  // if (plan && plan !== 'FREE') {
  //   const paymentResult = await processPayment(tenantId, PLANS[plan].price);
  //   expressionAttributeValues[':paymentId'] = paymentResult.id;
  //   expressionAttributeValues[':paymentStatus'] = paymentResult.status;
  // }

  const result = await dynamodb.update({
    TableName: MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: 'SUBSCRIPTION'
    },
    UpdateExpression: `SET ${updateExpression.join(', ')}`,
    ExpressionAttributeNames: expressionAttributeNames,
    ExpressionAttributeValues: expressionAttributeValues,
    ReturnValues: 'ALL_NEW'
  }).promise();

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify(result.Attributes)
  };
}