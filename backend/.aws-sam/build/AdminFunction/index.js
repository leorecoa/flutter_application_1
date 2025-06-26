const AWS = require('aws-sdk');
const MultiTenantMiddleware = require('../shared/multi-tenant');
const ResponseHelper = require('../shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

const handler = async (event) => {
  // Check if user is super admin
  if (!event.tenant.isSuperAdmin) {
    return ResponseHelper.forbidden('Super admin access required');
  }

  const { httpMethod, pathParameters, body } = event;
  const path = pathParameters?.proxy || '';
  const requestBody = body ? JSON.parse(body) : {};

  switch (`${httpMethod}:${path}`) {
    case 'GET:tenants':
      return await getAllTenants(event);
    
    case 'GET:usage':
      return await getUsageStats(event);
    
    case 'PATCH:tenants/disable':
      return await disableTenant(event, requestBody);
    
    case 'PATCH:tenants/enable':
      return await enableTenant(event, requestBody);
    
    case 'GET:stats':
      return await getGlobalStats(event);
    
    default:
      return ResponseHelper.notFound('Admin endpoint not found');
  }
};

async function getAllTenants(event) {
  try {
    const params = {
      TableName: process.env.MAIN_TABLE,
      FilterExpression: 'begins_with(PK, :pk) AND SK = :sk',
      ExpressionAttributeValues: {
        ':pk': 'TENANT#',
        ':sk': 'CONFIG'
      }
    };

    const result = await dynamodb.scan(params).promise();
    const tenants = result.Items;

    // Get user count for each tenant
    const tenantsWithStats = await Promise.all(
      tenants.map(async (tenant) => {
        const userParams = {
          TableName: process.env.MAIN_TABLE,
          KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
          ExpressionAttributeValues: {
            ':pk': tenant.PK,
            ':sk': 'USER#'
          }
        };

        const userResult = await dynamodb.query(userParams).promise();
        
        return {
          ...tenant,
          userCount: userResult.Items.length,
          lastActivity: tenant.updatedAt || tenant.createdAt
        };
      })
    );

    return ResponseHelper.success({
      tenants: tenantsWithStats,
      totalTenants: tenants.length
    });

  } catch (error) {
    console.error('Get all tenants error:', error);
    return ResponseHelper.serverError('Failed to get tenants');
  }
}

async function getUsageStats(event) {
  try {
    // Get all appointments from last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const params = {
      TableName: process.env.MAIN_TABLE,
      FilterExpression: 'contains(PK, :appointments) AND #date >= :date',
      ExpressionAttributeNames: {
        '#date': 'date'
      },
      ExpressionAttributeValues: {
        ':appointments': '#APPOINTMENTS',
        ':date': thirtyDaysAgo.toISOString()
      }
    };

    const result = await dynamodb.scan(params).promise();
    const appointments = result.Items;

    // Group by tenant
    const tenantUsage = {};
    appointments.forEach(apt => {
      const tenantId = apt.PK.split('#')[1];
      if (!tenantUsage[tenantId]) {
        tenantUsage[tenantId] = {
          tenantId,
          appointmentCount: 0,
          revenue: 0
        };
      }
      tenantUsage[tenantId].appointmentCount++;
      tenantUsage[tenantId].revenue += apt.price || 0;
    });

    const usage = Object.values(tenantUsage);

    return ResponseHelper.success({
      usage,
      summary: {
        totalAppointments: appointments.length,
        totalRevenue: usage.reduce((sum, u) => sum + u.revenue, 0),
        activeTenants: usage.length,
        period: '30 days'
      }
    });

  } catch (error) {
    console.error('Get usage stats error:', error);
    return ResponseHelper.serverError('Failed to get usage stats');
  }
}

async function disableTenant(event, body) {
  const { tenantId, reason } = body;

  if (!tenantId) {
    return ResponseHelper.error('Tenant ID required');
  }

  try {
    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: 'CONFIG'
      },
      UpdateExpression: 'SET isActive = :active, disabledAt = :date, disabledReason = :reason',
      ExpressionAttributeValues: {
        ':active': false,
        ':date': new Date().toISOString(),
        ':reason': reason || 'Disabled by admin'
      },
      ReturnValues: 'ALL_NEW'
    };

    const result = await dynamodb.update(params).promise();

    return ResponseHelper.success({
      tenant: result.Attributes,
      message: 'Tenant disabled successfully'
    });

  } catch (error) {
    console.error('Disable tenant error:', error);
    return ResponseHelper.serverError('Failed to disable tenant');
  }
}

async function enableTenant(event, body) {
  const { tenantId } = body;

  if (!tenantId) {
    return ResponseHelper.error('Tenant ID required');
  }

  try {
    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: 'CONFIG'
      },
      UpdateExpression: 'SET isActive = :active REMOVE disabledAt, disabledReason',
      ExpressionAttributeValues: {
        ':active': true
      },
      ReturnValues: 'ALL_NEW'
    };

    const result = await dynamodb.update(params).promise();

    return ResponseHelper.success({
      tenant: result.Attributes,
      message: 'Tenant enabled successfully'
    });

  } catch (error) {
    console.error('Enable tenant error:', error);
    return ResponseHelper.serverError('Failed to enable tenant');
  }
}

async function getGlobalStats(event) {
  try {
    // Get tenant count
    const tenantParams = {
      TableName: process.env.MAIN_TABLE,
      FilterExpression: 'begins_with(PK, :pk) AND SK = :sk',
      ExpressionAttributeValues: {
        ':pk': 'TENANT#',
        ':sk': 'CONFIG'
      }
    };

    const tenantResult = await dynamodb.scan(tenantParams).promise();
    const tenants = tenantResult.Items;
    const activeTenants = tenants.filter(t => t.isActive !== false);

    // Get total appointments this month
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    
    const appointmentParams = {
      TableName: process.env.MAIN_TABLE,
      FilterExpression: 'contains(PK, :appointments) AND #date >= :date',
      ExpressionAttributeNames: {
        '#date': 'date'
      },
      ExpressionAttributeValues: {
        ':appointments': '#APPOINTMENTS',
        ':date': startOfMonth.toISOString()
      }
    };

    const appointmentResult = await dynamodb.scan(appointmentParams).promise();
    const appointments = appointmentResult.Items;

    const totalRevenue = appointments
      .filter(apt => apt.status === 'completed')
      .reduce((sum, apt) => sum + (apt.price || 0), 0);

    return ResponseHelper.success({
      totalTenants: tenants.length,
      activeTenants: activeTenants.length,
      inactiveTenants: tenants.length - activeTenants.length,
      monthlyAppointments: appointments.length,
      monthlyRevenue: totalRevenue,
      averageRevenuePerTenant: activeTenants.length > 0 ? totalRevenue / activeTenants.length : 0,
      period: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    });

  } catch (error) {
    console.error('Get global stats error:', error);
    return ResponseHelper.serverError('Failed to get global stats');
  }
}

exports.handler = MultiTenantMiddleware.withMultiTenant(handler);