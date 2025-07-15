class AppConstants {
  static const String appName = 'AgendaFácil';
  static const String appSlogan = 'Agendamentos fáceis e rápidos';
  static const String version = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://5wy56rw801.execute-api.us-east-1.amazonaws.com/prod';
  
  static const bool useRealApi = true; // Sempre usar API real agora
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}