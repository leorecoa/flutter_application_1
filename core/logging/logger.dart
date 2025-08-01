import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../config/environment_config.dart';

/// Provider para o serviço de logging
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// Níveis de log
enum LogLevel { debug, info, warning, error }

/// Classe para logging estruturado
class Logger {
  // Singleton para acesso global
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  // Nível mínimo de log
  LogLevel _minLevel = LogLevel.debug;

  /// Define o nível mínimo de log
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Log de debug
  static void debug(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    _instance._log(LogLevel.debug, message, error: error, context: context);
  }

  /// Log de informação
  static void info(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    _instance._log(LogLevel.info, message, error: error, context: context);
  }

  /// Log de aviso
  static void warning(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    _instance._log(LogLevel.warning, message, error: error, context: context);
  }

  /// Log de erro
  static void error(
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    _instance._log(LogLevel.error, message, error: error, context: context);
  }

  /// Método interno para logging
  void _log(
    LogLevel level,
    String message, {
    dynamic error,
    Map<String, dynamic>? context,
  }) {
    // Verifica se o nível de log é suficiente
    if (level.index < _minLevel.index) return;

    // Formata a mensagem de log
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    // Cria o objeto de log estruturado
    final logObject = {
      'timestamp': timestamp,
      'level': levelStr,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (context != null) 'context': context,
    };

    // Imprime o log localmente
    developer.log(
      message,
      time: DateTime.now(),
      name: 'AGENDEMAIS',
      error: error,
      level: _getLevelValue(level),
    );

    // Envia logs para CloudWatch apenas em produção ou se explicitamente habilitado
    if (EnvironmentConfig.shouldLogToCloud) {
      _sendToCloudWatch(logObject);
    }
  }

  /// Envia logs para AWS CloudWatch
  void _sendToCloudWatch(Map<String, dynamic> logObject) {
    // Implementação real seria feita aqui
    // Desativado em desenvolvimento para economizar custos
  }

  /// Converte o nível de log para um valor inteiro
  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
