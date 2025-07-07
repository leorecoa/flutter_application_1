class AppConstants {
  static const String appName = 'AGENDEMAIS';
  static const String appSlogan = 'Seu negócio sempre em primeiro lugar';
  static const String version = '1.0.0';
  
  // API Configuration - OPTIMIZED
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://5wy56rw801.execute-api.us-east-1.amazonaws.com/prod',
  );
  
  static const bool useRealApi = true;
  // Reduced from 30s to 8s for better UX
  static const Duration requestTimeout = Duration(seconds: 8);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  
  // Performance Constants
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const int pageSize = 20;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}