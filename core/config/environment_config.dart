import 'package:flutter/foundation.dart';

/// Configuração de ambiente para controlar comportamentos específicos
/// em desenvolvimento e produção
class EnvironmentConfig {
  /// Ambiente atual (dev, staging, prod)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// Flag para usar AWS real ou serviços simulados
  static final bool useRealAws = _getBoolFromEnv(
    'USE_REAL_AWS',
    defaultValue: environment == 'prod',
  );

  /// Flag para habilitar analytics
  static final bool enableAnalytics = _getBoolFromEnv(
    'ENABLE_ANALYTICS',
    defaultValue: environment == 'prod',
  );

  /// Flag para habilitar logging detalhado
  static final bool enableVerboseLogging = _getBoolFromEnv(
    'ENABLE_VERBOSE_LOGGING',
    defaultValue: environment != 'prod',
  );

  /// Flag para usar APIs reais ou simuladas
  static final bool useRealApis = _getBoolFromEnv(
    'USE_REAL_APIS',
    defaultValue: environment == 'prod',
  );

  /// Flag para habilitar multi-tenant
  static final bool enableMultiTenant = _getBoolFromEnv(
    'ENABLE_MULTI_TENANT',
    defaultValue: true,
  );

  /// URL base da API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: environment == 'prod'
        ? 'https://api.agendemais.com'
        : environment == 'staging'
        ? 'https://staging-api.agendemais.com'
        : 'https://dev-api.agendemais.com',
  );

  /// Região da AWS
  static const String awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'us-east-1',
  );

  /// ID do pool de identidade do Cognito
  static const String cognitoIdentityPoolId = String.fromEnvironment(
    'COGNITO_IDENTITY_POOL_ID',
  );

  /// ID do pool de usuários do Cognito
  static const String cognitoUserPoolId = String.fromEnvironment(
    'COGNITO_USER_POOL_ID',
  );

  /// ID do cliente do app no Cognito
  static const String cognitoAppClientId = String.fromEnvironment(
    'COGNITO_APP_CLIENT_ID',
  );

  /// Nome do bucket S3
  static const String s3BucketName = String.fromEnvironment(
    'S3_BUCKET_NAME',
    defaultValue: 'agendemais-$environment',
  );

  /// Endpoint do GraphQL
  static const String graphqlEndpoint = String.fromEnvironment(
    'GRAPHQL_ENDPOINT',
    defaultValue: '$apiBaseUrl/graphql',
  );

  /// Verifica se estamos em modo de desenvolvimento
  static bool get isDevelopment => environment == 'dev';

  /// Verifica se estamos em modo de staging
  static bool get isStaging => environment == 'staging';

  /// Verifica se estamos em modo de produção
  static bool get isProduction => environment == 'prod';

  /// Obtém um valor booleano de uma variável de ambiente
  static bool _getBoolFromEnv(String name, {required bool defaultValue}) {
    final value = String.fromEnvironment(name);
    if (value.isEmpty) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Imprime a configuração atual para debug
  static void printConfig() {
    debugPrint('=== ENVIRONMENT CONFIG ===');
    debugPrint('Environment: $environment');
    debugPrint('Use Real AWS: $useRealAws');
    debugPrint('Enable Analytics: $enableAnalytics');
    debugPrint('Enable Verbose Logging: $enableVerboseLogging');
    debugPrint('Use Real APIs: $useRealApis');
    debugPrint('Enable Multi-Tenant: $enableMultiTenant');
    debugPrint('API Base URL: $apiBaseUrl');
    debugPrint('AWS Region: $awsRegion');
    debugPrint('GraphQL Endpoint: $graphqlEndpoint');
    debugPrint('========================');
  }
}
