import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/config/environment_config.dart';

/// Serviço para detectar e prevenir chamadas indesejadas a serviços AWS
/// durante o desenvolvimento
class AwsCallDetector {
  static final AwsCallDetector _instance = AwsCallDetector._internal();
  factory AwsCallDetector() => _instance;
  AwsCallDetector._internal();

  // Lista de chamadas de rede detectadas
  final List<_NetworkCall> _detectedCalls = [];

  // Configuração
  bool _isEnabled = true;
  bool _blockCalls = false;
  final Set<String> _allowedHosts = {};
  final Set<String> _blockedHosts = {
    'cognito-idp.',
    'cognito-identity.',
    'dynamodb.',
    's3.',
    'execute-api.',
    'pinpoint.',
    'lambda.',
    'appsync.',
  };

  /// Inicializa o detector
  void initialize() {
    // Só ativa em desenvolvimento
    _isEnabled =
        EnvironmentConfig.isDevelopment && !EnvironmentConfig.useRealAws;
    _blockCalls =
        EnvironmentConfig.isDevelopment && !EnvironmentConfig.useRealAws;

    if (_isEnabled) {
      Logger.info(
        'AWS Call Detector inicializado',
        context: {
          'blockCalls': _blockCalls,
          'blockedHosts': _blockedHosts.toList(),
        },
      );
    }
  }

  /// Adiciona um host à lista de permitidos
  void allowHost(String host) {
    _allowedHosts.add(host);
    Logger.info(
      'Host adicionado à lista de permitidos',
      context: {'host': host},
    );
  }

  /// Adiciona um host à lista de bloqueados
  void blockHost(String host) {
    _blockedHosts.add(host);
    Logger.info(
      'Host adicionado à lista de bloqueados',
      context: {'host': host},
    );
  }

  /// Verifica se uma URL deve ser bloqueada
  bool shouldBlockUrl(String url) {
    if (!_isEnabled || !_blockCalls) return false;

    // Verifica se a URL está na lista de permitidos
    for (final host in _allowedHosts) {
      if (url.contains(host)) return false;
    }

    // Verifica se a URL está na lista de bloqueados
    for (final host in _blockedHosts) {
      if (url.contains(host)) {
        _logBlockedCall(url);
        return true;
      }
    }

    return false;
  }

  /// Registra uma chamada de rede
  void trackNetworkCall(String url, String method) {
    if (!_isEnabled) return;

    final call = _NetworkCall(
      url: url,
      method: method,
      timestamp: DateTime.now(),
    );

    _detectedCalls.add(call);

    // Verifica se é uma chamada AWS
    bool isAwsCall = false;
    for (final host in _blockedHosts) {
      if (url.contains(host)) {
        isAwsCall = true;
        break;
      }
    }

    if (isAwsCall) {
      Logger.warning(
        'Chamada AWS detectada',
        context: {'url': url, 'method': method, 'blocked': _blockCalls},
      );
    }
  }

  /// Registra uma chamada bloqueada
  void _logBlockedCall(String url) {
    Logger.warning(
      'Chamada AWS bloqueada',
      context: {
        'url': url,
        'reason': 'Desenvolvimento local com useRealAws=false',
        'solution':
            'Use MockAmplifyService ou defina EnvironmentConfig.useRealAws=true',
      },
    );
  }

  /// Gera um relatório de chamadas detectadas
  String generateReport() {
    if (_detectedCalls.isEmpty) {
      return 'Nenhuma chamada AWS detectada.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Relatório de Chamadas AWS ===');
    buffer.writeln('Total de chamadas: ${_detectedCalls.length}');

    // Agrupa por host
    final callsByHost = <String, int>{};
    for (final call in _detectedCalls) {
      final uri = Uri.parse(call.url);
      final host = uri.host;
      callsByHost[host] = (callsByHost[host] ?? 0) + 1;
    }

    buffer.writeln('\nChamadas por host:');
    callsByHost.forEach((host, count) {
      buffer.writeln('- $host: $count chamadas');
    });

    // Últimas 10 chamadas
    buffer.writeln('\nÚltimas chamadas:');
    final recentCalls = _detectedCalls.reversed.take(10).toList();
    for (final call in recentCalls) {
      buffer.writeln(
        '- ${call.timestamp.toIso8601String()} | ${call.method} ${call.url}',
      );
    }

    return buffer.toString();
  }

  /// Limpa o histórico de chamadas
  void clearHistory() {
    _detectedCalls.clear();
  }

  /// Ativa ou desativa o bloqueio de chamadas
  set blockCalls(bool value) {
    _blockCalls = value;
    Logger.info('Bloqueio de chamadas AWS ${value ? 'ativado' : 'desativado'}');
  }

  /// Retorna se o bloqueio está ativado
  bool get isBlockingCalls => _blockCalls;
}

/// Representa uma chamada de rede detectada
class _NetworkCall {
  final String url;
  final String method;
  final DateTime timestamp;

  _NetworkCall({
    required this.url,
    required this.method,
    required this.timestamp,
  });
}
