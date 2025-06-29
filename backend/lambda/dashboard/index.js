const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('DashboardFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, requestContext } = event;
    
    const userId = requestContext?.authorizer?.claims?.sub;
    const tenantId = requestContext?.authorizer?.claims?.['custom:tenantId'];
    
    if (!userId || !tenantId) {
      return ResponseHelper.unauthorized('User not authenticated or tenant not found');
    }

    if (httpMethod === 'GET') {
      return await getDashboardStats(tenantId);
    }

    return ResponseHelper.notFound('Endpoint not found');
  } catch (error) {
    context.log('DashboardFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getDashboardStats(tenantId) {
  const now = new Date();
  const currentMonth = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0');
  
  // Query appointments for current month using GSI1
  const params = {
    TableName: process.env.MAIN_TABLE,
    IndexName: 'GSI1',
    KeyConditionExpression: 'GSI1PK = :gsi1pk AND begins_with(GSI1SK, :month)',
    FilterExpression: '#status = :status',
    ExpressionAttributeValues: {
      ':gsi1pk': `TENANT#${tenantId}#DATE`,
      ':month': currentMonth,
      ':status': 'completed'
    },
    ExpressionAttributeNames: {
      '#status': 'status'
    }
  };

  const appointmentsResult = await dynamodb.query(params).promise();

  // Get services and users data
  const [servicesResult, usersResult] = await Promise.all([
    dynamodb.query({
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}`,
        ':sk': 'SERVICE#'
      }
    }).promise(),
    dynamodb.query({
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}`,
        ':sk': 'USER#'
      }
    }).promise()
  ]);

  // Create lookup maps
  const servicesMap = {};
  servicesResult.Items.forEach(service => {
    servicesMap[service.serviceId] = service;
  });

  const usersMap = {};
  usersResult.Items.forEach(user => {
    usersMap[user.userId] = user;
  });

  // Calculate stats
  let totalRevenue = 0;
  const appointmentsByBarber = {};
  const serviceStats = {};

  appointmentsResult.Items.forEach(appointment => {
    const service = servicesMap[appointment.serviceId];
    const user = usersMap[appointment.userId];
    
    if (service) {
      const price = service.price || 0;
      totalRevenue += price;

      // Count by barber
      const userName = user?.name || 'Unknown';
      appointmentsByBarber[userName] = (appointmentsByBarber[userName] || 0) + 1;

      // Count by service
      const serviceName = service.name;
      if (!serviceStats[serviceName]) {
        serviceStats[serviceName] = { name: serviceName, count: 0, total: 0 };
      }
      serviceStats[serviceName].count += 1;
      serviceStats[serviceName].total += price;
    }
  });

  const topServices = Object.values(serviceStats)
    .sort((a, b) => b.total - a.total)
    .slice(0, 5);

  return ResponseHelper.success({
    totalRevenue,
    appointmentsByBarber,
    topServices,
    period: {
      month: currentMonth,
      totalAppointments: appointmentsResult.Items.length
    }
  });
}