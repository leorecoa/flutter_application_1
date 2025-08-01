import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';

/// Provider para o alternador de ambiente
final environmentSwitcherProvider = Provider<EnvironmentSwitcher>((ref) {
  return EnvironmentSwitcherImpl();
});

/// Interface para o alternador de ambiente
abstract class EnvironmentSwitcher {
  /// Alterna para o ambiente de desenvolvimento
  Future<bool> switchToDevelopment();
  
  /// Alterna para o ambiente de produção
  Future<bool> switchToProduction();
  
  /// Obtém o ambiente atual
  Future<String> getCurrentEnvironment();
  
  /// Verifica se o ambiente está configurado corretamente
  Future<Map<String, bool>> checkEnvironmentConfiguration();
}

/// Implementação do alternador de ambiente
class EnvironmentSwitcherImpl implements EnvironmentSwitcher {
  static const String _envConfigPath = 'lib/core/config/environment_config.dart';
  static const String _devFlag = 'static const bool isDevelopmentMode = true;';
  static const String _prodFlag = 'static const bool isDevelopmentMode = false;';
  static const String _disableAwsFlag = 'static const bool disableAwsServices = true;';
  static const String _enableAwsFlag = 'static const bool disableAwsServices = false;';
  
  @override
  Future<bool> switchToDevelopment() async {
    try {
      final file = File(_envConfigPath);
      if (!await file.exists()) {
        Logger.error('Arquivo de configuração de ambiente não encontrado');
        return false;
      }
      
      String content = await file.readAsString();
      
      // Altera para modo de desenvolvimento
      content = content.replaceAll(_prodFlag, _devFlag);
      
      // Desabilita serviços AWS
      content = content.replaceAll(_enableAwsFlag, _disableAwsFlag);
      
      await file.writeAsString(content);
      
      Logger.info('Ambiente alterado para desenvolvimento');
      return true;
    } catch (e) {
      Logger.error('Erro ao alternar para ambiente de desenvolvimento', error: e);
      return false;
    }
  }
  
  @override
  Future<bool> switchToProduction() async {
    try {
      final file = File(_envConfigPath);
      if (!await file.exists()) {
        Logger.error('Arquivo de configuração de ambiente não encontrado');
        return false;
      }
      
      String content = await file.readAsString();
      
      // Altera para modo de produção
      content = content.replaceAll(_devFlag, _prodFlag);
      
      // Habilita serviços AWS
      content = content.replaceAll(_disableAwsFlag, _enableAwsFlag);
      
      await file.writeAsString(content);
      
      Logger.info('Ambiente alterado para produção');
      return true;
    } catch (e) {
      Logger.error('Erro ao alternar para ambiente de produção', error: e);
      return false;
    }
  }
  
  @override
  Future<String> getCurrentEnvironment() async {
    try {
      final file = File(_envConfigPath);
      if (!await file.exists()) {
        return 'unknown';
      }
      
      final content = await file.readAsString();
      
      if (content.contains(_devFlag)) {
        return 'development';
      } else if (content.contains(_prodFlag)) {
        return 'production';
      } else {
        return 'unknown';
      }
    } catch (e) {
      Logger.error('Erro ao obter ambiente atual', error: e);
      return 'error';
    }
  }
  
  @override
  Future<Map<String, bool>> checkEnvironmentConfiguration() async {
    final results = <String, bool>{};
    
    try {
      final file = File(_envConfigPath);
      if (!await file.exists()) {
        results['environment_config_exists'] = false;
        return results;
      }
      
      results['environment_config_exists'] = true;
      
      final content = await file.readAsString();
      
      // Verifica modo de desenvolvimento
      results['is_development_mode'] = content.contains(_devFlag);
      
      // Verifica se AWS está desabilitado
      results['aws_services_disabled'] = content.contains(_disableAwsFlag);
      
      // Verifica se a configuração é consistente
      final isDev = results['is_development_mode'] ?? false;
      final awsDisabled = results['aws_services_disabled'] ?? false;
      
      results['configuration_consistent'] = isDev == awsDisabled;
      
      // Verifica pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      if (await pubspecFile.exists()) {
        final pubspecContent = await pubspecFile.readAsString();
        
        // Verifica se as dependências AWS estão comentadas em desenvolvimento
        final awsDepsCommented = pubspecContent.contains('# amplify_flutter:');
        results['aws_dependencies_commented'] = awsDepsCommented;
        
        // Verifica se a configuração do pubspec é consistente com o ambiente
        results['pubspec_consistent'] = isDev == awsDepsCommented;
      }
    } catch (e) {
      Logger.error('Erro ao verificar configuração do ambiente', error: e);
    }
    
    return results;
  }
}