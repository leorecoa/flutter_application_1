const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Dashboard Event:', JSON.stringify(event, null, 2));

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

    return await getDashboardStats(userId);

  } catch (error) {
    console.error('Dashboard Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno do servidor' })
    };
  }
};

async function getDashboardStats(userId) {
  try {
    const result = await dynamodb.query({
      TableName: process.env.APPOINTMENTS_TABLE,
      IndexName: 'userId-index',
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: { ':userId': userId }
    }).promise();

    const appointments = result.Items;
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // Calcular métricas
    const appointmentsToday = appointments.filter(apt => {
      const aptDate = new Date(apt.dateTime);
      return aptDate >= today && aptDate < new Date(today.getTime() + 24 * 60 * 60 * 1000);
    }).length;

    const monthlyRevenue = appointments
      .filter(apt => new Date(apt.dateTime) >= thisMonth && apt.status === 'completed')
      .reduce((sum, apt) => sum + apt.price, 0);

    const totalClients = new Set(appointments.map(apt => apt.clientName)).size;

    const nextAppointments = appointments
      .filter(apt => new Date(apt.dateTime) > now)
      .sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime))
      .slice(0, 3)
      .map(apt => ({
        id: apt.id,
        clientName: apt.clientName,
        service: apt.service,
        dateTime: apt.dateTime,
        price: apt.price,
        status: apt.status
      }));

    const stats = {
      appointmentsToday,
      totalClients,
      monthlyRevenue,
      activeServices: 12, // Mock - implementar contagem real
      weeklyGrowth: Math.random() * 20 + 5, // Mock - calcular crescimento real
      satisfactionRate: 4.7 + Math.random() * 0.3,
      nextAppointments
    };

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: stats
      })
    };

  } catch (error) {
    console.error('Get Dashboard Stats Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao buscar estatísticas' })
    };
  }
}