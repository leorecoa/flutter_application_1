const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('RelatorioFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, queryStringParameters, requestContext } = event;
    const path = pathParameters?.proxy || '';
    
    const userId = requestContext?.authorizer?.claims?.sub;
    const tenantId = requestContext?.authorizer?.claims?.['custom:tenantId'];
    
    if (!userId || !tenantId) {
      return ResponseHelper.unauthorized('User not authenticated or tenant not found');
    }

    switch (`${httpMethod}:${path}`) {
      case 'GET:appointments':
        return await getAppointmentsReport(tenantId, queryStringParameters);
      case 'GET:revenue':
        return await getRevenueReport(tenantId, queryStringParameters);
      case 'GET:clients':
        return await getClientsReport(tenantId, queryStringParameters);
      case 'GET:services-performance':
        return await getServicesPerformanceReport(tenantId, queryStringParameters);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'relatorio' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('RelatorioFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getAppointmentsReport(tenantId, queryParams) {
  const { startDate, endDate, status } = queryParams || {};
  
  if (!startDate || !endDate) {
    return ResponseHelper.error('startDate and endDate are required (YYYY-MM-DD format)');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'appointmentDate BETWEEN :startDate AND :endDate',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'APPOINTMENT#',
      ':startDate': startDate,
      ':endDate': endDate
    }
  };

  if (status) {
    params.FilterExpression += ' AND #status = :status';
    params.ExpressionAttributeValues[':status'] = status;
    params.ExpressionAttributeNames = { '#status': 'status' };
  }

  const result = await dynamodb.query(params).promise();
  
  const summary = {
    totalAppointments: result.Items.length,
    byStatus: {},
    byDate: {}
  };

  result.Items.forEach(appointment => {
    // Count by status
    const appointmentStatus = appointment.status || 'unknown';
    summary.byStatus[appointmentStatus] = (summary.byStatus[appointmentStatus] || 0) + 1;
    
    // Count by date
    const date = appointment.appointmentDate;
    summary.byDate[date] = (summary.byDate[date] || 0) + 1;
  });

  return ResponseHelper.success({
    period: { startDate, endDate },
    summary,
    appointments: result.Items
  });
}

async function getRevenueReport(tenantId, queryParams) {
  const { startDate, endDate } = queryParams || {};
  
  if (!startDate || !endDate) {
    return ResponseHelper.error('startDate and endDate are required (YYYY-MM-DD format)');
  }

  // Get appointments
  const appointmentsParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'appointmentDate BETWEEN :startDate AND :endDate AND #status = :status',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'APPOINTMENT#',
      ':startDate': startDate,
      ':endDate': endDate,
      ':status': 'completed'
    },
    ExpressionAttributeNames: { '#status': 'status' }
  };

  const appointmentsResult = await dynamodb.query(appointmentsParams).promise();

  // Get services to get prices
  const servicesParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'SERVICE#'
    }
  };

  const servicesResult = await dynamodb.query(servicesParams).promise();
  const servicesMap = {};
  servicesResult.Items.forEach(service => {
    servicesMap[service.serviceId] = service;
  });

  let totalRevenue = 0;
  const revenueByDate = {};
  const revenueByService = {};

  appointmentsResult.Items.forEach(appointment => {
    const service = servicesMap[appointment.serviceId];
    if (service) {
      const price = service.price || 0;
      totalRevenue += price;
      
      // Revenue by date
      const date = appointment.appointmentDate;
      revenueByDate[date] = (revenueByDate[date] || 0) + price;
      
      // Revenue by service
      const serviceName = service.name;
      revenueByService[serviceName] = (revenueByService[serviceName] || 0) + price;
    }
  });

  return ResponseHelper.success({
    period: { startDate, endDate },
    totalRevenue,
    completedAppointments: appointmentsResult.Items.length,
    averageTicket: appointmentsResult.Items.length > 0 ? totalRevenue / appointmentsResult.Items.length : 0,
    revenueByDate,
    revenueByService
  });
}

async function getClientsReport(tenantId, queryParams) {
  const { startDate, endDate } = queryParams || {};
  
  if (!startDate || !endDate) {
    return ResponseHelper.error('startDate and endDate are required (YYYY-MM-DD format)');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'appointmentDate BETWEEN :startDate AND :endDate',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'APPOINTMENT#',
      ':startDate': startDate,
      ':endDate': endDate
    }
  };

  const result = await dynamodb.query(params).promise();
  
  const clientsMap = {};
  const uniqueClients = new Set();

  result.Items.forEach(appointment => {
    const clientKey = appointment.clientPhone || appointment.clientEmail;
    if (clientKey) {
      uniqueClients.add(clientKey);
      
      if (!clientsMap[clientKey]) {
        clientsMap[clientKey] = {
          name: appointment.clientName,
          phone: appointment.clientPhone,
          email: appointment.clientEmail,
          appointmentsCount: 0,
          lastAppointment: appointment.appointmentDate
        };
      }
      
      clientsMap[clientKey].appointmentsCount++;
      
      if (appointment.appointmentDate > clientsMap[clientKey].lastAppointment) {
        clientsMap[clientKey].lastAppointment = appointment.appointmentDate;
      }
    }
  });

  return ResponseHelper.success({
    period: { startDate, endDate },
    totalUniqueClients: uniqueClients.size,
    totalAppointments: result.Items.length,
    clients: Object.values(clientsMap)
  });
}

async function getServicesPerformanceReport(tenantId, queryParams) {
  const { startDate, endDate } = queryParams || {};
  
  if (!startDate || !endDate) {
    return ResponseHelper.error('startDate and endDate are required (YYYY-MM-DD format)');
  }

  // Get appointments
  const appointmentsParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'appointmentDate BETWEEN :startDate AND :endDate',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'APPOINTMENT#',
      ':startDate': startDate,
      ':endDate': endDate
    }
  };

  const appointmentsResult = await dynamodb.query(appointmentsParams).promise();

  // Get services
  const servicesParams = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'SERVICE#'
    }
  };

  const servicesResult = await dynamodb.query(servicesParams).promise();
  const servicesMap = {};
  servicesResult.Items.forEach(service => {
    servicesMap[service.serviceId] = {
      ...service,
      appointmentsCount: 0,
      revenue: 0,
      completedCount: 0
    };
  });

  appointmentsResult.Items.forEach(appointment => {
    const service = servicesMap[appointment.serviceId];
    if (service) {
      service.appointmentsCount++;
      
      if (appointment.status === 'completed') {
        service.completedCount++;
        service.revenue += service.price || 0;
      }
    }
  });

  return ResponseHelper.success({
    period: { startDate, endDate },
    services: Object.values(servicesMap)
  });
}