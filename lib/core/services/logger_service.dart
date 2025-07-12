import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    if (_isProduction && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [${level.name.toUpperCase()}] $message';
    
    developer.log(
      logMessage,
      name: 'AGENDEMAIS',
      error: error,
      stackTrace: stackTrace,
      level: _getLevelValue(level),
    );

    // Em produção, enviar logs para serviço externo
    if (_isProduction && level == LogLevel.error) {
      _sendToExternalService(logMessage, error, stackTrace);
    }
  }

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

  void _sendToExternalService(String message, Object? error, StackTrace? stackTrace) {
    // Implementar integração com CloudWatch, Sentry, etc.
    // Por enquanto, apenas log local
    developer.log('EXTERNAL_LOG: $message', name: 'AGENDEMAIS_EXTERNAL');
  }
}