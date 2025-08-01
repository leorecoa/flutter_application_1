/// Configurações de ambiente
class EnvironmentConfig {
  /// Verifica se estamos em ambiente de desenvolvimento
  static bool get isDevelopment => true; // Altere para false em produção
  
  /// Verifica se estamos em ambiente de produção
  static bool get isProduction => !isDevelopment;
  
  /// URL base da API
  static String get apiBaseUrl => isDevelopment
      ? 'https://api-dev.agendemais.com/v1'
      : 'https://api.agendemais.com/v1';
  
  /// Habilita logs verbosos
  static bool get enableVerboseLogging => isDevelopment;
  
  /// Usa serviços AWS reais (em vez de mocks)
  static bool get useRealAws => false; // Altere para true em produção
}