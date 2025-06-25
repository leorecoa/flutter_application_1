const { handler } = require('../lambda/auth/index');

describe('Auth Function Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Login Endpoint', () => {
    test('should return success for valid login', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'login' },
        body: JSON.stringify({
          email: 'test@example.com',
          password: 'password123'
        })
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.user.email).toBe('test@example.com');
      expect(body.data.token).toBeDefined();
    });

    test('should return error for missing credentials', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'login' },
        body: JSON.stringify({
          email: 'test@example.com'
          // missing password
        })
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
      expect(body.error.message).toBe('Email and password are required');
    });
  });

  describe('Register Endpoint', () => {
    test('should register user successfully', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'register' },
        body: JSON.stringify({
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          businessName: 'Test Business',
          businessType: 'salon'
        })
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.user.email).toBe('test@example.com');
      expect(body.data.user.name).toBe('Test User');
    });

    test('should return error for missing required fields', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'register' },
        body: JSON.stringify({
          email: 'test@example.com',
          password: 'password123'
          // missing name, businessName, businessType
        })
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
      expect(body.error.message).toBe('Missing required fields');
    });
  });

  describe('CORS Handling', () => {
    test('should handle OPTIONS request', async () => {
      const event = {
        httpMethod: 'OPTIONS'
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      expect(result.headers['Access-Control-Allow-Origin']).toBe('*');
      expect(result.headers['Access-Control-Allow-Methods']).toBeDefined();
    });
  });

  describe('Error Handling', () => {
    test('should handle invalid JSON in body', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'login' },
        body: 'invalid json'
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(500);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
    });

    test('should return 404 for unknown endpoint', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'unknown' }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(404);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
      expect(body.error.message).toBe('Endpoint not found');
    });
  });
});