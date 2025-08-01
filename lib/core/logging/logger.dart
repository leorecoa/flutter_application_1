import 'dart:developer' as developer;
import 'package:flutter_application_1/core/config/environment_config.dart';

/// Classe para logging centralizado
class Logger {
  /// Registra uma mensagem de informação
  static void info(String message, {Map<String, dynamic>? context}) {
    _log('INFO', message, context: context);
  }
  
  /// Registra uma mensagem de aviso
  static void warning(String message, {Map<String, dynamic>? context}) {
    _log('WARNING', message, context: context);
  }
  
  /// Registra uma mensagem de erro
  static void error(String message, {dynamic error, Map<String, dynamic>? context}) {
    final errorContext = {...?context, 'error': error?.toString()};
    _log('ERROR', message, context: errorContext);
  }
  
  /// Registra uma mensagem de debug (apenas em desenvolvimento)
  static void debug(String message, {Map<String, dynamic>? context}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      _log('DEBUG', message, context: context);
    }
  }
  
  /// Método interno para registrar mensagens
  static void _log(String level, String message, {Map<String, dynamic>? context}) {
    final timestamp = DateTime.now().toIso8601String();
    final contextString = context != null ? ' - Context: $context' : '';
    
    final logMessage = '[$level] $timestamp - $message$contextString';
    
    // Em desenvolvimento, imprime no console
    if (EnvironmentConfig.isDevelopment) {
      developer.log(logMessage, name: 'AGENDEMAIS');
    }
    
    // Em produção, envia para o serviço de logging (CloudWatch, etc.)
    if (EnvironmentConfig.isProduction && EnvironmentConfig.useRealAws) {
      // Implementação para enviar logs para AWS CloudWatch
      // Isso seria implementado em uma classe separada
    }
  }
}