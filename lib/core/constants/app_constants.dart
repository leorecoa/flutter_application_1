class AppConstants {
  static const String appName = 'AGENDEMAIS';
  static const String appSlogan = 'Seu negócio sempre em primeiro lugar';
  static const String version = '1.0.0';
  
  // AWS API Configuration - Production
  static const String apiBaseUrl = String.fromEnvironment(
    'AWS_API_ENDPOINT',
    defaultValue: 'https://5wy56rw801.execute-api.us-east-1.amazonaws.com/prod',
  );
  
  // AWS Cognito Configuration - Production
  static const String cognitoUserPoolId = String.fromEnvironment(
    'COGNITO_USER_POOL_ID',
    defaultValue: '',
  );
  
  static const String cognitoAppClientId = String.fromEnvironment(
    'COGNITO_APP_CLIENT_ID', 
    defaultValue: '',
  );
  
  static const String cognitoIdentityPoolId = String.fromEnvironment(
    'COGNITO_IDENTITY_POOL_ID',
    defaultValue: '',
  );
  
  static const String awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'us-east-1',
  );
  
  // API Configuration
  static const bool useRealApi = true;
  static const Duration requestTimeout = Duration(seconds: 8);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  
  // Performance Constants
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const int pageSize = 20;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  
  // Security
  static const List<String> publicRoutes = [
    '/',
    '/login', 
    '/register',
    '/splash',
    '/manifest.json',
    '/favicon.ico',
  ];
}