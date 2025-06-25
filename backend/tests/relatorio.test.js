const { handler } = require('../lambda/relatorio/index');

// Mock the middleware
jest.mock('../lambda/shared/multi-tenant', () => ({
  withMultiTenant: (fn) => fn
}));

describe('Relatorio Function Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Services Report', () => {
    test('should generate services report successfully', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'servicos' },
        queryStringParameters: {
          startDate: '2024-01-01',
          endDate: '2024-01-31'
        },
        tenant: {
          id: 'test-tenant-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.services).toBeDefined();
      expect(body.data.summary).toBeDefined();
    });
  });

  describe('Financial Report', () => {
    test('should generate financial report with grouping', async () => {
      const event = {
        httpMethod: 'GET',
        pathParameters: { proxy: 'financeiro' },
        queryStringParameters: {
          startDate: '2024-01-01',
          endDate: '2024-01-31',
          groupBy: 'month'
        },
        tenant: {
          id: 'test-tenant-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.periods).toBeDefined();
      expect(body.data.summary.totalRevenue).toBeDefined();
    });
  });

  describe('Export Report', () => {
    test('should export report to CSV successfully', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'export' },
        body: JSON.stringify({
          reportType: 'financeiro',
          format: 'csv',
          params: {
            startDate: '2024-01-01',
            endDate: '2024-01-31'
          }
        }),
        tenant: {
          id: 'test-tenant-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(200);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(true);
      expect(body.data.downloadUrl).toBeDefined();
      expect(body.data.fileName).toBeDefined();
    });

    test('should return error for invalid report type', async () => {
      const event = {
        httpMethod: 'POST',
        pathParameters: { proxy: 'export' },
        body: JSON.stringify({
          reportType: 'invalid',
          format: 'csv'
        }),
        tenant: {
          id: 'test-tenant-id'
        }
      };

      const result = await handler(event);
      
      expect(result.statusCode).toBe(400);
      const body = JSON.parse(result.body);
      expect(body.success).toBe(false);
      expect(body.error.message).toBe('Invalid report type');
    });
  });
});