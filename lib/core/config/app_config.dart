import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações globais do aplicativo
class AppConfig {
  /// Ambiente atual (dev, staging, prod)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'dev';
  
  /// Verifica se é ambiente de produção
  static bool get isProduction => environment == 'prod';
  
  /// Verifica se é ambiente de desenvolvimento
  static bool get isDevelopment => environment == 'dev';
  
  /// Verifica se é ambiente de staging
  static bool get isStaging => environment == 'staging';
  
  /// URL base da API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.agendafacil.app/dev';
  
  /// Habilitar analytics
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  
  /// Habilitar relatório de erros
  static bool get enableCrashReporting => dotenv.env['ENABLE_CRASH_REPORTING'] == 'true';
  
  /// Versão do aplicativo
  static const String appVersion = '1.0.0';
  
  /// Build number
  static const String buildNumber = '1';
}