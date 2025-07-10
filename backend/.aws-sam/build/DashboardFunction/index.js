const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
        'Content-Type': 'application/json'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        const authHeader = event.headers.Authorization || event.headers.authorization;
        if (!authHeader) {
            return {
                statusCode: 401,
                headers,
                body: JSON.stringify({ success: false, message: 'Token necessário' })
            };
        }

        const token = authHeader.replace('Bearer ', '');
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        
        return await getDashboardStats(userId, headers);
    } catch (error) {
        console.error('Dashboard error:', error);
        return {
            statusCode: error.message.includes('jwt') ? 401 : 500,
            headers,
            body: JSON.stringify({ 
                success: false, 
                message: error.message.includes('jwt') ? 'Token inválido' : 'Erro interno'
            })
        };
    }
};



async function getDashboardStats(userId, headers) {
    const params = {
        TableName: process.env.APPOINTMENTS_TABLE,
        IndexName: 'userId-index',
        KeyConditionExpression: 'userId = :userId',
        ExpressionAttributeValues: { ':userId': userId }
    };

    const result = await dynamodb.query(params).promise();
    const appointments = result.Items;

    const today = new Date().toISOString().split('T')[0];
    const thisMonth = new Date().toISOString().substring(0, 7);

    const stats = {
        appointmentsToday: appointments.filter(a => a.dateTime.startsWith(today)).length,
        totalClients: new Set(appointments.map(a => a.clientName)).size,
        monthlyRevenue: appointments
            .filter(a => a.dateTime.startsWith(thisMonth) && a.status === 'completed')
            .reduce((sum, a) => sum + (a.price || 0), 0),
        activeServices: new Set(appointments.map(a => a.service)).size,
        weeklyGrowth: 15, // Mock - calcular real depois
        satisfactionRate: 4.8, // Mock - implementar avaliações
        nextAppointments: appointments
            .filter(a => new Date(a.dateTime) > new Date())
            .sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime))
            .slice(0, 5)
    };

    return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
            success: true,
            data: stats
        })
    };
}