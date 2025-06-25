const { handler } = require('../lambda/admin/index');

// Mock the middleware
jest.mock('../lambda/shared/multi-tenant', () => ({
  withMultiTenant: (fn) => fn
}));

describe('Admin Function Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Super Admin Access Control', () => {
    test('should allow access for super admin', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'tenants' },
        tenant: {
          isSuperAdmin: true,
          email: 'admin@agendafacil.com'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
    });

    test('should deny access for non-super admin', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'tenants' },
        tenant: {
          isSuperAdmin: false,
          email: 'user@example.com'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(403);
      const body = JSON.parse(result.body);
      expect(body.error.message).toBe('Super admin access required');
    });
  });

  describe('Get All Tenants', () => {
    test('should return all tenants for super admin', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'tenants' },
        tenant: {
          isSuperAdmin: true
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.tenants).toBeDefined();
      expect(body.data.totalTenants).toBeDefined();
    });
  });

  describe('Disable Tenant', () => {
    test('should disable tenant successfully', async () => {
      const event = {
        httpMethod: 'PATCH',
        pathParameters: { proxy: 'tenants/disable' },
        body: JSON.stringify({
          tenantId: 'test-tenant-id',
          reason: 'Policy violation'
        }),
        tenant: {
          isSuperAdmin: true
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.message).toBe('Tenant disabled successfully');
    });

    test('should return error when tenant ID missing', async () => {
      const event = {
        httpMethod: 'PATCH',
        pathParameters: { proxy: 'tenants/disable' },
        body: JSON.stringify({
          reason: 'Policy violation'
          // missing tenantId
        }),
        tenant: {
          isSuperAdmin: true
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.error.message).toBe('Tenant ID required');
    });
  });

  describe('Get Global Stats', () => {
    test('should return global statistics', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'stats' },
        tenant: {
          isSuperAdmin: true
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.totalTenants).toBeDefined();
      expect(body.data.activeTenants).toBeDefined();
      expect(body.data.monthlyAppointments).toBeDefined();
    });
  });
});