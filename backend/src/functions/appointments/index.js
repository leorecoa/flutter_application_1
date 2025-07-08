const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        const userId = await getUserId(event);
        const { httpMethod } = event;
        const body = JSON.parse(event.body || '{}');

        if (httpMethod === 'GET') {
            return await getAppointments(userId);
        } else if (httpMethod === 'POST') {
            return await createAppointment(userId, body);
        } else if (httpMethod === 'PUT') {
            const appointmentId = event.pathParameters?.id;
            return await updateAppointment(userId, appointmentId, body);
        }

        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ success: false, message: 'Método não permitido' })
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ success: false, message: error.message })
        };
    }
};

async function getUserId(event) {
    const token = event.headers.Authorization?.replace('Bearer ', '');
    if (!token) throw new Error('Token não fornecido');
    
    const decoded = jwt.verify(token, JWT_SECRET);
    return decoded.userId;
}

async function getAppointments(userId) {
    const params = {
        TableName: process.env.APPOINTMENTS_TABLE,
        IndexName: 'userId-index',
        KeyConditionExpression: 'userId = :userId',
        ExpressionAttributeValues: { ':userId': userId }
    };

    const result = await dynamodb.query(params).promise();

    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization'
        },
        body: JSON.stringify({
            success: true,
            data: result.Items
        })
    };
}

async function createAppointment(userId, data) {
    const appointmentId = uuidv4();
    
    const params = {
        TableName: process.env.APPOINTMENTS_TABLE,
        Item: {
            id: appointmentId,
            userId,
            clientName: data.clientName,
            clientPhone: data.clientPhone,
            service: data.service,
            dateTime: data.dateTime,
            price: data.price,
            status: 'scheduled',
            notes: data.notes || '',
            createdAt: new Date().toISOString()
        }
    };

    await dynamodb.put(params).promise();

    return {
        statusCode: 201,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization'
        },
        body: JSON.stringify({
            success: true,
            data: params.Item
        })
    };
}

async function updateAppointment(userId, appointmentId, data) {
    const params = {
        TableName: process.env.APPOINTMENTS_TABLE,
        Key: { id: appointmentId },
        UpdateExpression: 'SET #status = :status, notes = :notes',
        ExpressionAttributeNames: { '#status': 'status' },
        ExpressionAttributeValues: {
            ':status': data.status || 'scheduled',
            ':notes': data.notes || ''
        },
        ReturnValues: 'ALL_NEW'
    };

    const result = await dynamodb.update(params).promise();

    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization'
        },
        body: JSON.stringify({
            success: true,
            data: result.Attributes
        })
    };
}