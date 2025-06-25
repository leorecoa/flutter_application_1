const AWS = require('aws-sdk');
const MultiTenantMiddleware = require('../shared/multi-tenant');
const ResponseHelper = require('../shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3();

const handler = async (event) => {
  const { httpMethod, pathParameters, queryStringParameters } = event;
  const path = pathParameters?.proxy || '';
  const params = queryStringParameters || {};

  switch (`${httpMethod}:${path}`) {
    case 'GET:servicos':
      return await getServicesReport(event, params);
    
    case 'GET:clientes':
      return await getClientsReport(event, params);
    
    case 'GET:financeiro':
      return await getFinancialReport(event, params);
    
    case 'POST:export':
      return await exportReport(event, JSON.parse(event.body || '{}'));
    
    default:
      return ResponseHelper.notFound('Endpoint not found');
  }
};

async function getServicesReport(event, params) {
  const { id: tenantId } = event.tenant;
  const { startDate, endDate } = params;

  try {
    // Get all services for tenant
    const servicesParams = {
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#SERVICES`,
        ':sk': 'SERVICE#'
      }
    };

    const servicesResult = await dynamodb.query(servicesParams).promise();
    const services = servicesResult.Items;

    // Get appointments for each service in date range
    const appointmentsParams = {
      TableName: process.env.MAIN_TABLE,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :pk',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#APPOINTMENTS`
      }
    };

    if (startDate && endDate) {
      appointmentsParams.FilterExpression = '#date BETWEEN :start AND :end';
      appointmentsParams.ExpressionAttributeNames = { '#date': 'date' };
      appointmentsParams.ExpressionAttributeValues[':start'] = startDate;
      appointmentsParams.ExpressionAttributeValues[':end'] = endDate;
    }

    const appointmentsResult = await dynamodb.query(appointmentsParams).promise();
    const appointments = appointmentsResult.Items;

    // Calculate service statistics
    const serviceStats = services.map(service => {
      const serviceAppointments = appointments.filter(apt => apt.serviceId === service.serviceId);
      const totalRevenue = serviceAppointments.reduce((sum, apt) => sum + (apt.price || 0), 0);
      
      return {
        ...service,
        totalAppointments: serviceAppointments.length,
        totalRevenue,
        averagePrice: serviceAppointments.length > 0 ? totalRevenue / serviceAppointments.length : 0
      };
    });

    return ResponseHelper.success({
      services: serviceStats,
      summary: {
        totalServices: services.length,
        totalAppointments: appointments.length,
        totalRevenue: serviceStats.reduce((sum, s) => sum + s.totalRevenue, 0)
      }
    });

  } catch (error) {
    console.error('Services report error:', error);
    return ResponseHelper.serverError('Failed to generate services report');
  }
}

async function getClientsReport(event, params) {
  const { id: tenantId } = event.tenant;
  const { startDate, endDate } = params;

  try {
    // Get all appointments to extract client data
    const appointmentsParams = {
      TableName: process.env.MAIN_TABLE,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :pk',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#APPOINTMENTS`
      }
    };

    if (startDate && endDate) {
      appointmentsParams.FilterExpression = '#date BETWEEN :start AND :end';
      appointmentsParams.ExpressionAttributeNames = { '#date': 'date' };
      appointmentsParams.ExpressionAttributeValues[':start'] = startDate;
      appointmentsParams.ExpressionAttributeValues[':end'] = endDate;
    }

    const result = await dynamodb.query(appointmentsParams).promise();
    const appointments = result.Items;

    // Group by client
    const clientStats = {};
    appointments.forEach(apt => {
      const clientKey = apt.clientEmail || apt.clientPhone;
      if (!clientStats[clientKey]) {
        clientStats[clientKey] = {
          name: apt.clientName,
          email: apt.clientEmail,
          phone: apt.clientPhone,
          totalAppointments: 0,
          totalSpent: 0,
          lastVisit: null,
          firstVisit: null
        };
      }

      clientStats[clientKey].totalAppointments++;
      clientStats[clientKey].totalSpent += apt.price || 0;
      
      const aptDate = new Date(apt.date);
      if (!clientStats[clientKey].lastVisit || aptDate > new Date(clientStats[clientKey].lastVisit)) {
        clientStats[clientKey].lastVisit = apt.date;
      }
      if (!clientStats[clientKey].firstVisit || aptDate < new Date(clientStats[clientKey].firstVisit)) {
        clientStats[clientKey].firstVisit = apt.date;
      }
    });

    const clients = Object.values(clientStats);

    return ResponseHelper.success({
      clients,
      summary: {
        totalClients: clients.length,
        totalAppointments: appointments.length,
        averageSpentPerClient: clients.length > 0 ? clients.reduce((sum, c) => sum + c.totalSpent, 0) / clients.length : 0
      }
    });

  } catch (error) {
    console.error('Clients report error:', error);
    return ResponseHelper.serverError('Failed to generate clients report');
  }
}

async function getFinancialReport(event, params) {
  const { id: tenantId } = event.tenant;
  const { startDate, endDate, groupBy = 'day' } = params;

  try {
    const appointmentsParams = {
      TableName: process.env.MAIN_TABLE,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :pk',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#APPOINTMENTS`
      }
    };

    if (startDate && endDate) {
      appointmentsParams.FilterExpression = '#date BETWEEN :start AND :end AND #status = :status';
      appointmentsParams.ExpressionAttributeNames = { '#date': 'date', '#status': 'status' };
      appointmentsParams.ExpressionAttributeValues[':start'] = startDate;
      appointmentsParams.ExpressionAttributeValues[':end'] = endDate;
      appointmentsParams.ExpressionAttributeValues[':status'] = 'completed';
    }

    const result = await dynamodb.query(appointmentsParams).promise();
    const appointments = result.Items.filter(apt => apt.status === 'completed');

    // Group by time period
    const revenueByPeriod = {};
    appointments.forEach(apt => {
      const date = new Date(apt.date);
      let periodKey;
      
      switch (groupBy) {
        case 'month':
          periodKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
          break;
        case 'week':
          const weekStart = new Date(date);
          weekStart.setDate(date.getDate() - date.getDay());
          periodKey = weekStart.toISOString().split('T')[0];
          break;
        default: // day
          periodKey = date.toISOString().split('T')[0];
      }

      if (!revenueByPeriod[periodKey]) {
        revenueByPeriod[periodKey] = {
          period: periodKey,
          revenue: 0,
          appointments: 0
        };
      }

      revenueByPeriod[periodKey].revenue += apt.price || 0;
      revenueByPeriod[periodKey].appointments++;
    });

    const periods = Object.values(revenueByPeriod).sort((a, b) => a.period.localeCompare(b.period));
    const totalRevenue = periods.reduce((sum, p) => sum + p.revenue, 0);

    return ResponseHelper.success({
      periods,
      summary: {
        totalRevenue,
        totalAppointments: appointments.length,
        averageRevenuePerAppointment: appointments.length > 0 ? totalRevenue / appointments.length : 0,
        averageRevenuePerPeriod: periods.length > 0 ? totalRevenue / periods.length : 0
      }
    });

  } catch (error) {
    console.error('Financial report error:', error);
    return ResponseHelper.serverError('Failed to generate financial report');
  }
}

async function exportReport(event, body) {
  const { id: tenantId } = event.tenant;
  const { reportType, format = 'csv', params = {} } = body;

  try {
    let reportData;
    
    // Get report data based on type
    switch (reportType) {
      case 'servicos':
        const servicesReport = await getServicesReport(event, params);
        reportData = JSON.parse(servicesReport.body).data.services;
        break;
      case 'clientes':
        const clientsReport = await getClientsReport(event, params);
        reportData = JSON.parse(clientsReport.body).data.clients;
        break;
      case 'financeiro':
        const financialReport = await getFinancialReport(event, params);
        reportData = JSON.parse(financialReport.body).data.periods;
        break;
      default:
        return ResponseHelper.error('Invalid report type');
    }

    // Generate CSV content
    let csvContent = '';
    if (reportData.length > 0) {
      const headers = Object.keys(reportData[0]).join(',');
      const rows = reportData.map(row => Object.values(row).join(','));
      csvContent = [headers, ...rows].join('\n');
    }

    // Upload to S3
    const fileName = `reports/${tenantId}/${reportType}-${Date.now()}.${format}`;
    await s3.putObject({
      Bucket: process.env.S3_BUCKET,
      Key: fileName,
      Body: csvContent,
      ContentType: format === 'csv' ? 'text/csv' : 'application/json',
      ACL: 'private'
    }).promise();

    // Generate presigned URL
    const downloadUrl = s3.getSignedUrl('getObject', {
      Bucket: process.env.S3_BUCKET,
      Key: fileName,
      Expires: 3600 // 1 hour
    });

    return ResponseHelper.success({
      downloadUrl,
      fileName,
      recordCount: reportData.length,
      message: 'Report exported successfully'
    });

  } catch (error) {
    console.error('Export report error:', error);
    return ResponseHelper.serverError('Failed to export report');
  }
}

exports.handler = MultiTenantMiddleware.withMultiTenant(handler);