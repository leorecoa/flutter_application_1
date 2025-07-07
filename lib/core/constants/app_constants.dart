class AppConstants {
  static const String appName = 'AGENDEMAIS';
  static const String appSlogan = 'Seu negócio sempre em primeiro lugar';
  static const String version = '1.0.0';
  
  // API
  static const String baseUrl = 'https://api.agendemais.com';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}