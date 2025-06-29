const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('DashboardFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, requestContext } = event;
    const path = pathParameters?.proxy || '';
    
    const userId = requestContext?.authorizer?.claims?.sub;
    const tenantId = requestContext?.authorizer?.claims?.['custom:tenantId'];
    
    if (!userId || !tenantId) {
      return ResponseHelper.unauthorized('User not authenticated or tenant not found');
    }

    switch (`${httpMethod}:${path}`) {
      case 'GET:':
      case 'GET:stats':
        return await getDashboardStats(tenantId);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'dashboard' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('DashboardFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getDashboardStats(tenantId) {
  const now = new Date();
  const currentMonth = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0');
  const startOfMonth = `${currentMonth}-01`;
  const endOfMonth = `${currentMonth}-31`;

  // Get appointments for current month
  const appointmentsParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'appointmentDate BETWEEN :startDate AND :endDate AND #status = :status',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'APPOINTMENT#',
      ':startDate': startOfMonth,
      ':endDate': endOfMonth,
      ':status': 'completed'
    },
    ExpressionAttributeNames: {
      '#status': 'status'
    }
  };

  const appointmentsResult = await dynamodb.query(appointmentsParams).promise();

  // Get services data
  const servicesParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'SERVICE#'
    }
  };

  const servicesResult = await dynamodb.query(servicesParams).promise();

  // Get users data
  const usersParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'USER#'
    }
  };

  const usersResult = await dynamodb.query(usersParams).promise();

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

      // Count by barber/user
      const userName = user ? user.name : 'Unknown';
      appointmentsByBarber[userName] = (appointmentsByBarber[userName] || 0) + 1;

      // Count by service
      const serviceName = service.name;
      if (!serviceStats[serviceName]) {
        serviceStats[serviceName] = {
          name: serviceName,
          count: 0,
          total: 0
        };
      }
      serviceStats[serviceName].count += 1;
      serviceStats[serviceName].total += price;
    }
  });

  // Sort top services by revenue
  const topServices = Object.values(serviceStats)
    .sort((a, b) => b.total - a.total)
    .slice(0, 5)
    .map(service => ({
      name: service.name,
      total: service.total,
      count: service.count
    }));

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