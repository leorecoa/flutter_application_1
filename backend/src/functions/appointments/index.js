const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Appointments Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    const token = event.headers.Authorization?.replace('Bearer ', '');
    if (!token) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Token não fornecido' })
      };
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    const userId = decoded.userId;

    const { httpMethod, body, pathParameters } = event;
    const data = JSON.parse(body || '{}');

    if (httpMethod === 'GET') {
      return await getAppointments(userId);
    }

    if (httpMethod === 'POST') {
      return await createAppointment(userId, data);
    }

    if (httpMethod === 'PUT' && pathParameters?.id) {
      return await updateAppointment(userId, pathParameters.id, data);
    }

    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Endpoint não encontrado' })
    };

  } catch (error) {
    console.error('Appointments Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno do servidor' })
    };
  }
};

async function getAppointments(userId) {
  try {
    const result = await dynamodb.query({
      TableName: process.env.APPOINTMENTS_TABLE,
      IndexName: 'userId-index',
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: { ':userId': userId },
      ScanIndexForward: false
    }).promise();

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: result.Items
      })
    };

  } catch (error) {
    console.error('Get Appointments Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao buscar agendamentos' })
    };
  }
}

async function createAppointment(userId, { clientName, clientPhone, service, dateTime, price, notes }) {
  if (!clientName || !service || !dateTime || !price) {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Dados obrigatórios não fornecidos' })
    };
  }

  try {
    const appointmentId = uuidv4();
    const appointment = {
      id: appointmentId,
      userId,
      clientName,
      clientPhone: clientPhone || '',
      service,
      dateTime,
      price: parseFloat(price),
      status: 'scheduled',
      notes: notes || '',
      createdAt: new Date().toISOString()
    };

    await dynamodb.put({
      TableName: process.env.APPOINTMENTS_TABLE,
      Item: appointment
    }).promise();

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: appointment,
        message: 'Agendamento criado com sucesso'
      })
    };

  } catch (error) {
    console.error('Create Appointment Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao criar agendamento' })
    };
  }
}

async function updateAppointment(userId, appointmentId, { status, notes }) {
  try {
    const updateExpression = [];
    const expressionAttributeValues = {};
    const expressionAttributeNames = {};

    if (status) {
      updateExpression.push('#status = :status');
      expressionAttributeNames['#status'] = 'status';
      expressionAttributeValues[':status'] = status;
    }

    if (notes !== undefined) {
      updateExpression.push('notes = :notes');
      expressionAttributeValues[':notes'] = notes;
    }

    if (updateExpression.length === 0) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Nenhum campo para atualizar' })
      };
    }

    const result = await dynamodb.update({
      TableName: process.env.APPOINTMENTS_TABLE,
      Key: { id: appointmentId },
      UpdateExpression: `SET ${updateExpression.join(', ')}`,
      ExpressionAttributeValues: expressionAttributeValues,
      ExpressionAttributeNames: Object.keys(expressionAttributeNames).length > 0 ? expressionAttributeNames : undefined,
      ConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ...expressionAttributeValues,
        ':userId': userId
      },
      ReturnValues: 'ALL_NEW'
    }).promise();

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: result.Attributes,
        message: 'Agendamento atualizado com sucesso'
      })
    };

  } catch (error) {
    console.error('Update Appointment Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao atualizar agendamento' })
    };
  }
}