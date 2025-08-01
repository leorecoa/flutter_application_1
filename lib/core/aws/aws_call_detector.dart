import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../config/environment_config.dart';

/// Provider para o detector de chamadas AWS
final awsCallDetectorProvider = Provider<AwsCallDetector>((ref) {
  return AwsCallDetectorImpl();
});

/// Interface para o detector de chamadas AWS
abstract class AwsCallDetector {
  /// Inicia o monitoramento de chamadas AWS
  void startMonitoring();

  /// Para o monitoramento de chamadas AWS
  void stopMonitoring();

  /// Registra uma tentativa de chamada AWS
  void logAwsCallAttempt(
    String service,
    String operation, {
    Map<String, dynamic>? parameters,
  });

  /// Obtém o relatório de chamadas AWS
  Map<String, List<Map<String, dynamic>>> getAwsCallReport();

  /// Limpa o relatório de chamadas AWS
  void clearAwsCallReport();
}

/// Implementação do detector de chamadas AWS
class AwsCallDetectorImpl implements AwsCallDetector {
  final Map<String, List<Map<String, dynamic>>> _awsCalls = {};
  bool _isMonitoring = false;

  @override
  void startMonitoring() {
    _isMonitoring = true;
    Logger.info('Monitoramento de chamadas AWS iniciado');
  }

  @override
  void stopMonitoring() {
    _isMonitoring = false;
    Logger.info('Monitoramento de chamadas AWS parado');
  }

  @override
  void logAwsCallAttempt(
    String service,
    String operation, {
    Map<String, dynamic>? parameters,
  }) {
    if (!_isMonitoring) return;

    // Verifica se estamos em modo de desenvolvimento com AWS desabilitado
    if (EnvironmentConfig.isDevelopmentMode &&
        EnvironmentConfig.disableAwsServices) {
      // Registra a tentativa de chamada AWS que deveria estar bloqueada
      Logger.warning(
        '⚠️ TENTATIVA DE CHAMADA AWS DETECTADA',
        context: {
          'service': service,
          'operation': operation,
          'parameters': parameters,
          'timestamp': DateTime.now().toIso8601String(),
          'stackTrace': StackTrace.current.toString(),
        },
      );

      // Adiciona ao relatório
      if (!_awsCalls.containsKey(service)) {
        _awsCalls[service] = [];
      }

      _awsCalls[service]!.add({
        'operation': operation,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'stackTrace': StackTrace.current.toString(),
      });

      // Em modo de desenvolvimento, lança uma exceção para facilitar a depuração
      assert(() {
        throw AssertionError(
          'Chamada AWS detectada enquanto AWS está desabilitado: $service.$operation',
        );
        return true;
      }());
    }
  }

  @override
  Map<String, List<Map<String, dynamic>>> getAwsCallReport() {
    return Map.from(_awsCalls);
  }

  @override
  void clearAwsCallReport() {
    _awsCalls.clear();
    Logger.info('Relatório de chamadas AWS limpo');
  }
}
