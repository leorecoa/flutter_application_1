import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'monitoring_service.dart';

/// Serviço para captura e relatório de erros
class ErrorReportingService {
  static final Logger _logger = Logger();
  
  /// Inicializa o serviço de relatório de erros
  static void init() {
    // Captura erros não tratados em código assíncrono
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!kReleaseMode) {
        // Em modo de desenvolvimento, mostra o erro no console
        FlutterError.dumpErrorToConsole(details);
      } else {
        // Em produção, envia para o serviço de monitoramento
        _reportError(details.exception, details.stack, details.context?.toString());
      }
    };
    
    // Captura erros não tratados em código síncrono
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }
  
  /// Reporta um erro para o serviço de monitoramento
  static Future<void> _reportError(
    dynamic error,
    StackTrace? stackTrace, [
    String? context,
  ]) async {
    try {
      final errorMessage = error.toString();
      final contextInfo = context ?? 'Erro não tratado';
      
      _logger.e(
        'Erro: $errorMessage',
        error: error,
        stackTrace: stackTrace,
      );
      
      // Envia para o serviço de monitoramento
      await MonitoringService.logError(
        contextInfo,
        errorMessage,
        stackTrace,
      );
      
    } catch (e) {
      // Evita loops infinitos se houver erro no próprio relatório
      _logger.e('Erro ao reportar erro: $e');
    }
  }
  
  /// Método público para reportar erros manualmente
  static Future<void> reportError(
    String context,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    await _reportError(error, stackTrace, context);
  }
}