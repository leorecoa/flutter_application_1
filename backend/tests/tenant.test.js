const { handler } = require('../lambda/tenant/index');

// Mock the middleware
jest.mock('../lambda/shared/multi-tenant', () => ({
  withMultiTenant: (fn) => fn,
  checkQuota: jest.fn().mockResolvedValue({ allowed: true })
}));

describe('Tenant Function Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Create Tenant', () => {
    test('should create tenant successfully', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'create' },
        body: JSON.stringify({
          name: 'Test Business',
          businessType: 'salon'
        }),
        tenant: {
          userId: 'test-user-id',
          email: 'test@example.com'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.tenant.name).toBe('Test Business');
      expect(body.data.tenant.tenantId).toBeDefined();
    });

    test('should return error for missing fields', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'create' },
        body: JSON.stringify({
          name: 'Test Business'
          // missing businessType
        }),
        tenant: {
          userId: 'test-user-id',
          email: 'test@example.com'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
      expect(body.error.message).toContain('Missing required fields');
    });
  });

  describe('Get Tenant Config', () => {
    test('should get tenant config successfully', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'config' },
        tenant: {
          id: 'test-tenant-id',
          userId: 'test-user-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
    });

    test('should return error when tenant ID missing', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'config' },
        tenant: {
          userId: 'test-user-id'
          // missing tenant id
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.error.message).toBe('Tenant ID required');
    });
  });

  describe('Update Tenant Config', () => {
    test('should update tenant config successfully', async () => {
      const event = {
        httpMethod: 'PUT',
        pathParameters: { proxy: 'config' },
        body: JSON.stringify({
          name: 'Updated Business Name',
          theme: {
            primaryColor: '#ff0000'
          }
        }),
        tenant: {
          id: 'test-tenant-id',
          userId: 'test-user-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.message).toBe('Tenant updated successfully');
    });
  });
});