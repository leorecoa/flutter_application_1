class AppConfig {
  static const String appName = 'AgendaFácil';
  static const String version = '1.0.0';
  
  // AWS Configuration
  static const String awsRegion = 'us-east-1';
  static const String apiGatewayUrl = 'https://vkbjulc69d.execute-api.us-east-1.amazonaws.com/dev';
  static const String cognitoUserPoolId = 'us-east-1_V0tcWz9Kj';
  static const String cognitoClientId = '4b4d5o9s2n83e225umf3bsr5o0';
  
  // External APIs
  static const String whatsappApiUrl = 'https://api.z-api.io';
  static const String whatsappToken = 'YOUR_WHATSAPP_TOKEN';
  static const String stripePublishableKey = 'pk_test_XXXXXXXXXXXXXXXX';
  static const String mercadoPagoPublicKey = 'TEST-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';
  
  // App Settings
  static const int maxFreeAppointments = 5;
  static const List<String> supportedLanguages = ['pt', 'en', 'es'];
  
  static Future<void> initialize() async {
    // Initialize AWS Amplify, Firebase, or other services
    // Configure error reporting (Sentry, Crashlytics)
    // Setup analytics
  }
}