import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment_config.dart';

/// Provider para o verificador de configuração AWS
final awsConfigCheckerProvider = Provider<AwsConfigChecker>((ref) {
  return AwsConfigCheckerImpl();
});

/// Interface para o verificador de configuração AWS
abstract class AwsConfigChecker {
  /// Verifica se há arquivos de configuração AWS
  Future<Map<String, bool>> checkAwsConfigFiles();

  /// Verifica se há variáveis de ambiente AWS
  Map<String, String?> checkAwsEnvironmentVariables();

  /// Verifica se há credenciais AWS
  Future<bool> checkAwsCredentials();

  /// Verifica se a configuração do ambiente está correta
  bool isEnvironmentConfigCorrect();

  /// Obtém recomendações para a configuração AWS
  List<String> getConfigurationRecommendations();
}

/// Implementação do verificador de configuração AWS
class AwsConfigCheckerImpl implements AwsConfigChecker {
  @override
  Future<Map<String, bool>> checkAwsConfigFiles() async {
    final results = <String, bool>{};

    // Verifica arquivos de configuração comuns
    final homeDir = _getHomeDirectory();
    if (homeDir != null) {
      final awsDir = Directory('$homeDir/.aws');
      results['~/.aws directory'] = await awsDir.exists();

      final credentialsFile = File('$homeDir/.aws/credentials');
      results['~/.aws/credentials'] = await credentialsFile.exists();

      final configFile = File('$homeDir/.aws/config');
      results['~/.aws/config'] = await configFile.exists();
    }

    // Verifica arquivos de configuração do projeto
    final amplifyDir = Directory('amplify');
    results['amplify directory'] = await amplifyDir.exists();

    final amplifyConfigFile = File('lib/amplifyconfiguration.dart');
    results['amplifyconfiguration.dart'] = await amplifyConfigFile.exists();

    return results;
  }

  @override
  Map<String, String?> checkAwsEnvironmentVariables() {
    final results = <String, String?>{};

    // Verifica variáveis de ambiente comuns
    results['AWS_ACCESS_KEY_ID'] = Platform.environment['AWS_ACCESS_KEY_ID'];
    results['AWS_SECRET_ACCESS_KEY'] =
        Platform.environment['AWS_SECRET_ACCESS_KEY'] != null ? '***' : null;
    results['AWS_SESSION_TOKEN'] =
        Platform.environment['AWS_SESSION_TOKEN'] != null ? '***' : null;
    results['AWS_REGION'] = Platform.environment['AWS_REGION'];
    results['AWS_PROFILE'] = Platform.environment['AWS_PROFILE'];

    return results;
  }

  @override
  Future<bool> checkAwsCredentials() async {
    // Verifica se há credenciais configuradas
    final envVars = checkAwsEnvironmentVariables();
    final hasEnvCredentials =
        envVars['AWS_ACCESS_KEY_ID'] != null &&
        envVars['AWS_SECRET_ACCESS_KEY'] != null;

    // Verifica se há arquivo de credenciais
    final configFiles = await checkAwsConfigFiles();
    final hasCredentialsFile = configFiles['~/.aws/credentials'] == true;

    return hasEnvCredentials || hasCredentialsFile;
  }

  @override
  bool isEnvironmentConfigCorrect() {
    // Verifica se a configuração do ambiente está correta para o modo atual
    if (EnvironmentConfig.isDevelopmentMode) {
      // Em modo de desenvolvimento, AWS deve estar desabilitado
      return EnvironmentConfig.disableAwsServices;
    } else {
      // Em modo de produção, AWS deve estar habilitado
      return !EnvironmentConfig.disableAwsServices;
    }
  }

  @override
  List<String> getConfigurationRecommendations() {
    final recommendations = <String>[];

    if (EnvironmentConfig.isDevelopmentMode) {
      if (!EnvironmentConfig.disableAwsServices) {
        recommendations.add(
          'Defina EnvironmentConfig.disableAwsServices como true para evitar custos durante o desenvolvimento',
        );
      }

      if (!EnvironmentConfig.disableCloudAnalytics) {
        recommendations.add(
          'Defina EnvironmentConfig.disableCloudAnalytics como true para evitar custos de analytics',
        );
      }

      if (!EnvironmentConfig.disableCloudLogging) {
        recommendations.add(
          'Defina EnvironmentConfig.disableCloudLogging como true para evitar custos de logging',
        );
      }
    } else {
      if (EnvironmentConfig.disableAwsServices) {
        recommendations.add(
          'Defina EnvironmentConfig.disableAwsServices como false para usar serviços AWS em produção',
        );
      }
    }

    return recommendations;
  }

  /// Obtém o diretório home do usuário
  String? _getHomeDirectory() {
    if (Platform.isWindows) {
      return Platform.environment['USERPROFILE'];
    } else {
      return Platform.environment['HOME'];
    }
  }
}
