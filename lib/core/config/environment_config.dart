/// Configurações para ambiente de desenvolvimento e produção
class EnvironmentConfig {
  // Definir como false em produção
  static const bool isDevelopmentMode = true;

  // Configurações para reduzir custos em desenvolvimento
  static const bool useLocalEmulators = true;
  static const bool disableCloudAnalytics = true;
  static const bool minimizeApiCalls = true;
  static const bool disableCloudLogging = true;
  static const bool disableAwsServices = true;

  // Endpoints para emuladores locais
  static const String localDynamoDbEndpoint = 'http://localhost:8000';
  static const String localApiEndpoint = 'http://localhost:3000';

  // Configurações de API
  static String get apiEndpoint => isDevelopmentMode && useLocalEmulators
      ? localApiEndpoint
      : 'https://api.agendemais.com/v1';

  // Configurações de armazenamento
  static const int maxCacheItems = 100;
  static const Duration cacheExpiration = Duration(minutes: 30);

  // Configurações de analytics
  static bool get shouldTrackAnalytics =>
      !isDevelopmentMode || !disableCloudAnalytics;

  // Configurações de logging
  static bool get shouldLogToCloud =>
      !isDevelopmentMode || !disableCloudLogging;

  // Configurações AWS
  static bool get useAwsServices => !isDevelopmentMode || !disableAwsServices;
}
