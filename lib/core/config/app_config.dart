class AppConfig {
  // API Base URL - será configurada dinamicamente
  static const String apiBaseUrl = String.fromEnvironment(
    'AWS_API_ENDPOINT',
    defaultValue: 'https://api.agendemais.com', // Fallback
  );
  
  // Environment
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'production',
  );
  
  // Debug mode
  static bool get isDebug => environment == 'development';
  
  // Production mode
  static bool get isProduction => environment == 'production';
  
  // App info
  static const String appName = 'AGENDEMAIS';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 15;
  
  // Payment config
  static const double defaultPlanPrice = 90.00;
  static const String defaultPlanDescription = 'Plano Premium - Corte + Barba';
  
  // PIX config (for display purposes)
  static const String pixBeneficiario = 'Leandro Jesse da Silva';
  static const String pixChave = '05359566493';
  static const String pixBanco = 'Banco PAM';
  
  // JWT config
  static const String jwtSecret = 'agendemais-secret-key-2024';
  
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // API paths
  static const String authPath = '/auth';
  static const String appointmentsPath = '/appointments';
  static const String paymentsPath = '/api/pagamento';
  static const String webhooksPath = '/api/webhook';
  
  // URLs
  static String get loginUrl => '$apiBaseUrl$authPath/login';
  static String get registerUrl => '$apiBaseUrl$authPath/register';
  static String get appointmentsUrl => '$apiBaseUrl$appointmentsPath';
  static String get pixPaymentUrl => '$apiBaseUrl$paymentsPath/pix';
  static String get stripePaymentUrl => '$apiBaseUrl$paymentsPath/stripe';
  
  // Colors (hex values)
  static const String primaryColorHex = '#667eea';
  static const String secondaryColorHex = '#764ba2';
  static const String successColorHex = '#4CAF50';
  static const String errorColorHex = '#F44336';
  static const String warningColorHex = '#FF9800';
  
  // Feature flags
  static const bool enablePixPayments = true;
  static const bool enableStripePayments = true;
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}