import 'dart:async';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/config/environment_config.dart';

/// Serviço para monitorar e estimar custos da AWS durante o desenvolvimento
class AwsCostMonitor {
  static final AwsCostMonitor _instance = AwsCostMonitor._internal();
  factory AwsCostMonitor() => _instance;
  AwsCostMonitor._internal();
  
  // Contadores de uso de serviços
  int _apiCalls = 0;
  int _authCalls = 0;
  int _storageCalls = 0;
  int _analyticsCalls = 0;
  
  // Custos estimados por operação (em USD)
  static const double _apiCallCost = 0.0000004; // $0.0004 por 1000 chamadas
  static const double _authCallCost = 0.00055;  // $0.55 por 1000 MAUs
  static const double _storageCallCost = 0.0000005; // $0.0005 por 1000 operações
  static const double _analyticsCallCost = 0.00001; // $0.01 por 1000 eventos
  
  // Limites de alerta
  static const int _apiCallWarningThreshold = 10000;
  static const int _authCallWarningThreshold = 100;
  static const int _storageCallWarningThreshold = 1000;
  static const int _analyticsCallWarningThreshold = 5000;
  
  // Timer para relatório periódico
  Timer? _reportTimer;
  
  /// Inicia o monitoramento de custos
  void startMonitoring() {
    if (EnvironmentConfig.isDevelopment) {
      _reportTimer = Timer.periodic(const Duration(hours: 1), (_) {
        _generateCostReport();
      });
      Logger.info('Monitoramento de custos AWS iniciado');
    }
  }
  
  /// Para o monitoramento de custos
  void stopMonitoring() {
    _reportTimer?.cancel();
    _reportTimer = null;
  }
  
  /// Registra uma chamada de API
  void trackApiCall(String operation) {
    if (!EnvironmentConfig.useRealAws) return;
    
    _apiCalls++;
    if (_apiCalls % _apiCallWarningThreshold == 0) {
      _warnAboutUsage('API', _apiCalls, _apiCallCost * _apiCalls);
    }
  }
  
  /// Registra uma chamada de autenticação
  void trackAuthCall(String operation) {
    if (!EnvironmentConfig.useRealAws) return;
    
    _authCalls++;
    if (_authCalls % _authCallWarningThreshold == 0) {
      _warnAboutUsage('Auth', _authCalls, _authCallCost * _authCalls);
    }
  }
  
  /// Registra uma operação de armazenamento
  void trackStorageOperation(String operation) {
    if (!EnvironmentConfig.useRealAws) return;
    
    _storageCalls++;
    if (_storageCalls % _storageCallWarningThreshold == 0) {
      _warnAboutUsage('Storage', _storageCalls, _storageCallCost * _storageCalls);
    }
  }
  
  /// Registra um evento de analytics
  void trackAnalyticsEvent(String eventName) {
    if (!EnvironmentConfig.useRealAws) return;
    
    _analyticsCalls++;
    if (_analyticsCalls % _analyticsCallWarningThreshold == 0) {
      _warnAboutUsage('Analytics', _analyticsCalls, _analyticsCallCost * _analyticsCalls);
    }
  }
  
  /// Gera um relatório de custos estimados
  void _generateCostReport() {
    if (!EnvironmentConfig.useRealAws) return;
    
    final apiCost = _apiCalls * _apiCallCost;
    final authCost = _authCalls * _authCallCost;
    final storageCost = _storageCalls * _storageCallCost;
    final analyticsCost = _analyticsCalls * _analyticsCallCost;
    final totalCost = apiCost + authCost + storageCost + analyticsCost;
    
    Logger.info('Relatório de custos AWS estimados', context: {
      'apiCalls': _apiCalls,
      'apiCost': '\$${apiCost.toStringAsFixed(4)}',
      'authCalls': _authCalls,
      'authCost': '\$${authCost.toStringAsFixed(4)}',
      'storageCalls': _storageCalls,
      'storageCost': '\$${storageCost.toStringAsFixed(4)}',
      'analyticsCalls': _analyticsCalls,
      'analyticsCost': '\$${analyticsCost.toStringAsFixed(4)}',
      'totalCost': '\$${totalCost.toStringAsFixed(4)}',
    });
  }
  
  /// Emite um aviso sobre uso excessivo de um serviço
  void _warnAboutUsage(String service, int calls, double cost) {
    Logger.warning('Alto uso de $service detectado', context: {
      'service': service,
      'calls': calls,
      'estimatedCost': '\$${cost.toStringAsFixed(4)}',
      'suggestion': 'Considere usar EnvironmentConfig.useRealAws = false em desenvolvimento',
    });
  }
  
  /// Retorna o custo total estimado
  double get estimatedTotalCost {
    return (_apiCalls * _apiCallCost) +
           (_authCalls * _authCallCost) +
           (_storageCalls * _storageCallCost) +
           (_analyticsCalls * _analyticsCallCost);
  }
  
  /// Reseta os contadores
  void reset() {
    _apiCalls = 0;
    _authCalls = 0;
    _storageCalls = 0;
    _analyticsCalls = 0;
  }
}