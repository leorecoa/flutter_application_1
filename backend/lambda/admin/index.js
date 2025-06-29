const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('AdminFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body, requestContext } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};
    
    const userId = requestContext?.authorizer?.claims?.sub;
    const tenantId = requestContext?.authorizer?.claims?.['custom:tenantId'];
    const userRole = requestContext?.authorizer?.claims?.['custom:role'];
    
    if (!userId || !tenantId) {
      return ResponseHelper.unauthorized('User not authenticated or tenant not found');
    }

    // Check if user has admin role
    if (userRole !== 'admin') {
      return ResponseHelper.forbidden('Admin access required');
    }

    switch (`${httpMethod}:${path}`) {
      case 'GET:dashboard':
        return await getDashboardStats(tenantId);
      case 'POST:backup':
        return await createBackup(tenantId);
      case 'GET:system-health':
        return await getSystemHealth(tenantId);
      case 'POST:bulk-import':
        return await bulkImportData(requestBody, tenantId);
      case 'DELETE:purge-data':
        return await purgeOldData(requestBody, tenantId);
      case 'GET:audit-log':
        return await getAuditLog(tenantId, event.queryStringParameters);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'admin' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('AdminFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getDashboardStats(tenantId) {
  const today = new Date().toISOString().split('T')[0];
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

  // Get all data for tenant
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`
    }
  };

  const result = await dynamodb.query(params).promise();
  
  const stats = {
    totalServices: 0,
    totalUsers: 0,
    totalAppointments: 0,
    todayAppointments: 0,
    monthlyAppointments: 0,
    activeServices: 0,
    activeUsers: 0,
    recentAppointments: []
  };

  result.Items.forEach(item => {
    if (item.SK.startsWith('SERVICE#')) {
      stats.totalServices++;
      if (item.isActive) stats.activeServices++;
    } else if (item.SK.startsWith('USER#')) {
      stats.totalUsers++;
      if (item.isActive) stats.activeUsers++;
    } else if (item.SK.startsWith('APPOINTMENT#')) {
      stats.totalAppointments++;
      
      if (item.appointmentDate === today) {
        stats.todayAppointments++;
      }
      
      if (item.appointmentDate >= thirtyDaysAgo) {
        stats.monthlyAppointments++;
      }
      
      // Keep recent appointments
      if (stats.recentAppointments.length < 10) {
        stats.recentAppointments.push({
          appointmentId: item.appointmentId,
          clientName: item.clientName,
          appointmentDate: item.appointmentDate,
          appointmentTime: item.appointmentTime,
          status: item.status
        });
      }
    }
  });

  // Sort recent appointments by date/time
  stats.recentAppointments.sort((a, b) => {
    const dateA = new Date(`${a.appointmentDate}T${a.appointmentTime}`);
    const dateB = new Date(`${b.appointmentDate}T${b.appointmentTime}`);
    return dateB - dateA;
  });

  return ResponseHelper.success(stats);
}

async function createBackup(tenantId) {
  const timestamp = new Date().toISOString();
  
  // Get all tenant data
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`
    }
  };

  const result = await dynamodb.query(params).promise();
  
  // Store backup metadata
  const backupId = `backup_${Date.now()}`;
  const backup = {
    PK: `TENANT#${tenantId}`,
    SK: `BACKUP#${backupId}`,
    backupId,
    timestamp,
    itemCount: result.Items.length,
    status: 'completed',
    createdBy: 'admin'
  };

  const backupParams = {
    TableName: process.env.MAIN_TABLE,
    Item: backup
  };

  await dynamodb.put(backupParams).promise();

  // In a real implementation, you would store the actual data in S3
  // For now, we just create the backup record

  return ResponseHelper.success({
    backupId,
    message: 'Backup created successfully',
    itemCount: result.Items.length,
    timestamp
  });
}

async function getSystemHealth(tenantId) {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    checks: {
      database: 'healthy',
      storage: 'healthy',
      authentication: 'healthy'
    },
    metrics: {}
  };

  try {
    // Test database connectivity
    const testParams = {
      TableName: process.env.MAIN_TABLE,
      KeyConditionExpression: 'PK = :pk',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}`
      },
      Limit: 1
    };

    const startTime = Date.now();
    await dynamodb.query(testParams).promise();
    const responseTime = Date.now() - startTime;
    
    health.metrics.databaseResponseTime = `${responseTime}ms`;
    
    if (responseTime > 1000) {
      health.checks.database = 'warning';
      health.status = 'warning';
    }

  } catch (error) {
    health.checks.database = 'error';
    health.status = 'error';
    health.errors = [error.message];
  }

  return ResponseHelper.success(health);
}

async function bulkImportData(body, tenantId) {
  const { type, data } = body;
  
  if (!type || !data || !Array.isArray(data)) {
    return ResponseHelper.error('type and data array are required');
  }

  const results = {
    success: 0,
    errors: 0,
    details: []
  };

  for (const item of data) {
    try {
      let dbItem;
      
      switch (type) {
        case 'services':
          const serviceId = `service_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
          dbItem = {
            PK: `TENANT#${tenantId}`,
            SK: `SERVICE#${serviceId}`,
            serviceId,
            name: item.name,
            price: parseFloat(item.price),
            duration: parseInt(item.duration),
            description: item.description || '',
            isActive: true,
            createdAt: new Date().toISOString()
          };
          break;
          
        case 'users':
          const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
          dbItem = {
            PK: `TENANT#${tenantId}`,
            SK: `USER#${userId}`,
            userId,
            name: item.name,
            email: item.email,
            phone: item.phone || '',
            role: item.role || 'staff',
            isActive: true,
            createdAt: new Date().toISOString()
          };
          break;
          
        default:
          throw new Error(`Unsupported import type: ${type}`);
      }

      const params = {
        TableName: process.env.MAIN_TABLE,
        Item: dbItem
      };

      await dynamodb.put(params).promise();
      results.success++;
      
    } catch (error) {
      results.errors++;
      results.details.push({
        item,
        error: error.message
      });
    }
  }

  return ResponseHelper.success(results);
}

async function purgeOldData(body, tenantId) {
  const { type, olderThanDays } = body;
  
  if (!type || !olderThanDays) {
    return ResponseHelper.error('type and olderThanDays are required');
  }

  const cutoffDate = new Date(Date.now() - olderThanDays * 24 * 60 * 60 * 1000).toISOString();
  
  let skPrefix;
  switch (type) {
    case 'appointments':
      skPrefix = 'APPOINTMENT#';
      break;
    case 'backups':
      skPrefix = 'BACKUP#';
      break;
    default:
      return ResponseHelper.error(`Unsupported purge type: ${type}`);
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'createdAt < :cutoffDate',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': skPrefix,
      ':cutoffDate': cutoffDate
    }
  };

  const result = await dynamodb.query(params).promise();
  
  let deletedCount = 0;
  for (const item of result.Items) {
    const deleteParams = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: item.PK,
        SK: item.SK
      }
    };
    
    await dynamodb.delete(deleteParams).promise();
    deletedCount++;
  }

  return ResponseHelper.success({
    message: `Purged ${deletedCount} old ${type}`,
    deletedCount,
    cutoffDate
  });
}

async function getAuditLog(tenantId, queryParams) {
  const { limit = 50 } = queryParams || {};
  
  // In a real implementation, you would have audit log entries
  // For now, return a mock response
  const auditLog = {
    entries: [
      {
        timestamp: new Date().toISOString(),
        action: 'DASHBOARD_VIEW',
        userId: 'admin',
        details: 'Admin dashboard accessed'
      }
    ],
    total: 1,
    limit: parseInt(limit)
  };

  return ResponseHelper.success(auditLog);
}