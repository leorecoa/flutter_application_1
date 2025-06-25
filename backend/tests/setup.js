// Global test setup
process.env.USERS_TABLE = 'test-users-table';
process.env.SERVICES_TABLE = 'test-services-table';
process.env.APPOINTMENTS_TABLE = 'test-appointments-table';
process.env.COGNITO_USER_POOL_ID = 'test-pool-id';
process.env.COGNITO_CLIENT_ID = 'test-client-id';
process.env.ENVIRONMENT = 'test';

// Mock AWS SDK
jest.mock('aws-sdk', () => ({
  DynamoDB: {
    DocumentClient: jest.fn(() => ({
      put: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({})
      }),
      get: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({ Item: {} })
      }),
      query: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({ Items: [] })
      }),
      scan: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({ Items: [] })
      }),
      update: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({ Attributes: {} })
      }),
      delete: jest.fn().mockReturnValue({
        promise: jest.fn().mockResolvedValue({})
      })
    }))
  },
  CognitoIdentityServiceProvider: jest.fn(() => ({
    adminCreateUser: jest.fn().mockReturnValue({
      promise: jest.fn().mockResolvedValue({ User: { Username: 'test-user' } })
    }),
    adminInitiateAuth: jest.fn().mockReturnValue({
      promise: jest.fn().mockResolvedValue({
        AuthenticationResult: {
          AccessToken: 'test-access-token',
          IdToken: 'test-id-token',
          RefreshToken: 'test-refresh-token'
        }
      })
    })
  }))
}));