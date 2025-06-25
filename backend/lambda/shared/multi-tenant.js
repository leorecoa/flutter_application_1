const jwt = require('jsonwebtoken');
const AWS = require('aws-sdk');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const cognito = new AWS.CognitoIdentityServiceProvider();

class MultiTenantMiddleware {
  static extractTenantFromToken(token) {
    try {
      const decoded = jwt.decode(token.replace('Bearer ', ''));
      return {
        userId: decoded.sub,
        email: decoded.email,
        tenantId: decoded['custom:tenantId'],
        plan: decoded['custom:plan'] || 'free',
        groups: decoded['cognito:groups'] || []
      };
    } catch (error) {
      throw new Error('Invalid token');
    }
  }

  static async validateTenantAccess(tenantId, userId) {
    const params = {
      TableName: process.env.MAIN_TABLE,
      Key: {
        PK: `TENANT#${tenantId}`,
        SK: `USER#${userId}`
      }
    };

    const result = await dynamodb.get(params).promise();
    return !!result.Item;
  }

  static async checkQuota(tenantId, plan, type = 'appointments') {
    if (plan === 'pro') return { allowed: true };

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    
    const params = {
      TableName: process.env.MAIN_TABLE,
      IndexName: 'GSI1',
      KeyConditionExpression: 'GSI1PK = :pk AND begins_with(GSI1SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `TENANT#${tenantId}#APPOINTMENTS`,
        ':sk': startOfMonth.toISOString().substring(0, 7) // YYYY-MM
      }
    };

    const result = await dynamodb.query(params).promise();
    const count = result.Items.length;
    const limit = 50; // Free plan limit

    return {
      allowed: count < limit,
      current: count,
      limit
    };
  }

  static isSuperAdmin(email, groups = []) {
    const superAdminEmails = ['admin@agendafacil.com'];
    return superAdminEmails.includes(email) || groups.includes('root');
  }

  static withMultiTenant(handler) {
    return async (event, context) => {
      try {
        // Extract token from Authorization header
        const authHeader = event.headers?.Authorization || event.headers?.authorization;
        if (!authHeader) {
          return {
            statusCode: 401,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ success: false, error: { message: 'Missing authorization token' } })
          };
        }

        // Extract user info from token
        const userInfo = this.extractTenantFromToken(authHeader);
        
        // Add tenant context to event
        event.tenant = {
          id: userInfo.tenantId,
          userId: userInfo.userId,
          email: userInfo.email,
          plan: userInfo.plan,
          groups: userInfo.groups,
          isSuperAdmin: this.isSuperAdmin(userInfo.email, userInfo.groups)
        };

        // Validate tenant access (except for tenant creation)
        if (userInfo.tenantId && !event.path?.includes('/tenants/create')) {
          const hasAccess = await this.validateTenantAccess(userInfo.tenantId, userInfo.userId);
          if (!hasAccess && !event.tenant.isSuperAdmin) {
            return {
              statusCode: 403,
              headers: { 'Access-Control-Allow-Origin': '*' },
              body: JSON.stringify({ success: false, error: { message: 'Tenant access denied' } })
            };
          }
        }

        return await handler(event, context);
      } catch (error) {
        console.error('Multi-tenant middleware error:', error);
        return {
          statusCode: 500,
          headers: { 'Access-Control-Allow-Origin': '*' },
          body: JSON.stringify({ success: false, error: { message: 'Internal server error' } })
        };
      }
    };
  }
}

module.exports = MultiTenantMiddleware;