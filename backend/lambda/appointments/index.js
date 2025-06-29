const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('AppointmentsFunction Event:', JSON.stringify(event, null, 2));

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
        return await createAppointment(requestBody, tenantId);
      case 'GET:':
        return await listAppointments(tenantId, event.queryStringParameters);
      case 'PUT:':
        return await updateAppointment(requestBody, tenantId);
      case 'DELETE:':
        return await cancelAppointment(requestBody.appointmentId, tenantId);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'appointments' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('AppointmentsFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function createAppointment(body, tenantId) {
  const { serviceId, clientName, clientPhone, clientEmail, appointmentDate, appointmentTime, notes } = body;

  if (!serviceId || !clientName || !appointmentDate || !appointmentTime) {
    return ResponseHelper.error('Missing required fields: serviceId, clientName, appointmentDate, appointmentTime');
  }

  const appointmentId = `appointment_${Date.now()}`;
  const appointment = {
    PK: `TENANT#${tenantId}`,
    SK: `APPOINTMENT#${appointmentId}`,
    GSI1PK: `TENANT#${tenantId}#DATE`,
    GSI1SK: `${appointmentDate}#${appointmentTime}`,
    appointmentId,
    serviceId,
    clientName,
    clientPhone: clientPhone || '',
    clientEmail: clientEmail || '',
    appointmentDate,
    appointmentTime,
    notes: notes || '',
    status: 'scheduled',
    createdAt: new Date().toISOString()
  };

  const params = {
    TableName: process.env.MAIN_TABLE,
    Item: appointment
  };

  await dynamodb.put(params).promise();
  return ResponseHelper.success(appointment, 201);
}

async function listAppointments(tenantId, queryParams) {
  const { date, status } = queryParams || {};
  
  let params;
  
  if (date) {
    // Query by date using GSI
    params = {
      TableName: process.env.MAIN_TABLE,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :gsi1pk AND begins_with(GSI1SK, :date)',
      ExpressionAttributeValues: {
        ':gsi1pk': `TENANT#${tenantId}#DATE`,
        ':date': date
      }
    };
    
    if (status) {
      params.FilterExpression = '#status = :status';
      params.ExpressionAttributeNames = { '#status': 'status' };
      params.ExpressionAttributeValues[':status'] = status;
    }
    
    const result = await dynamodb.query(params).promise();
    return ResponseHelper.success(result.Items);
  } else {
    // Query all appointments for tenant
    params = {
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}`,
        ':sk': 'APPOINTMENT#'
      }
    };
    
    if (status) {
      params.FilterExpression = '#status = :status';
      params.ExpressionAttributeNames = { '#status': 'status' };
      params.ExpressionAttributeValues[':status'] = status;
    }
    
    const result = await dynamodb.query(params).promise();
    return ResponseHelper.success(result.Items);
  }
}

async function updateAppointment(body, tenantId) {
  const { appointmentId, status, notes, appointmentDate, appointmentTime } = body;

  if (!appointmentId) {
    return ResponseHelper.error('appointmentId is required');
  }

  const updateExpression = [];
  const expressionValues = {};
  
  if (status) {
    updateExpression.push('#status = :status');
    expressionValues[':status'] = status;
  }
  if (notes !== undefined) {
    updateExpression.push('notes = :notes');
    expressionValues[':notes'] = notes;
  }
  if (appointmentDate && appointmentTime) {
    updateExpression.push('appointmentDate = :date, appointmentTime = :time, GSI1SK = :gsi1sk');
    expressionValues[':date'] = appointmentDate;
    expressionValues[':time'] = appointmentTime;
    expressionValues[':gsi1sk'] = `${appointmentDate}#${appointmentTime}`;
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `APPOINTMENT#${appointmentId}`
    },
    UpdateExpression: `SET ${updateExpression.join(', ')}`,
    ExpressionAttributeValues: expressionValues,
    ExpressionAttributeNames: status ? { '#status': 'status' } : undefined,
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return ResponseHelper.success(result.Attributes);
}

async function cancelAppointment(appointmentId, tenantId) {
  if (!appointmentId) {
    return ResponseHelper.error('appointmentId is required');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `APPOINTMENT#${appointmentId}`
    },
    UpdateExpression: 'SET #status = :status',
    ExpressionAttributeNames: { '#status': 'status' },
    ExpressionAttributeValues: { ':status': 'cancelled' },
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return ResponseHelper.success(result.Attributes);
}