import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../config/environment_config.dart';

/// Provider para o monitor de custos AWS
final awsCostMonitorProvider = Provider<AwsCostMonitor>((ref) {
  return AwsCostMonitorImpl();
});

/// Interface para o monitor de custos AWS
abstract class AwsCostMonitor {
  /// Inicia o monitoramento de custos AWS
  void startMonitoring();
  
  /// Para o monitoramento de custos AWS
  void stopMonitoring();
  
  /// Registra um uso de serviço AWS
  void logServiceUsage(String service, String operation, {Map<String, dynamic>? parameters});
  
  /// Obtém o relatório de custos estimados
  Map<String, double> getEstimatedCosts();
  
  /// Limpa o relatório de custos
  void clearCostReport();
  
  /// Verifica se há algum serviço AWS sendo usado que não deveria
  Future<List<Map<String, dynamic>>> checkForUnauthorizedUsage();
}

/// Implementação do monitor de custos AWS
class AwsCostMonitorImpl implements AwsCostMonitor {
  final Map<String, int> _serviceUsage = {};
  final Map<String, double> _costPerService = {
    'Cognito': 0.0055,    // $0.0055 por autenticação
    'S3_Storage': 0.023,  // $0.023 por GB/mês
    'S3_Request': 0.0004, // $0.0004 por 1000 requisições
    'Lambda': 0.0000002,  // $0.0000002 por requisição (primeiros 1M gratuitos)
    'DynamoDB': 0.00065,  // $0.00065 por hora de RCU/WCU (primeiros 25 gratuitos)
    'ApiGateway': 0.001,  // $1.00 por milhão de requisições
    'Pinpoint': 0.0001,   // $0.0001 por evento
  };
  bool _isMonitoring = false;
  
  @override
  void startMonitoring() {
    _isMonitoring = true;
    Logger.info('Monitoramento de custos AWS iniciado');
  }
  
  @override
  void stopMonitoring() {
    _isMonitoring = false;
    Logger.info('Monitoramento de custos AWS parado');
  }
  
  @override
  void logServiceUsage(String service, String operation, {Map<String, dynamic>? parameters}) {
    if (!_isMonitoring) return;
    
    // Mapeia o serviço e operação para uma chave de custo
    final costKey = _mapToCostKey(service, operation);
    
    // Incrementa o contador de uso
    _serviceUsage[costKey] = (_serviceUsage[costKey] ?? 0) + 1;
    
    // Registra o uso
    Logger.debug('Uso de serviço AWS registrado', context: {
      'service': service,
      'operation': operation,
      'costKey': costKey,
      'count': _serviceUsage[costKey],
    });
  }
  
  @override
  Map<String, double> getEstimatedCosts() {
    final estimatedCosts = <String, double>{};
    
    _serviceUsage.forEach((key, count) {
      final costPerUnit = _costPerService[key] ?? 0.0;
      estimatedCosts[key] = costPerUnit * count;
    });
    
    // Adiciona o custo total
    double total = 0.0;
    estimatedCosts.forEach((key, cost) {
      if (key != 'Total') {
        total += cost;
      }
    });
    estimatedCosts['Total'] = total;
    
    return estimatedCosts;
  }
  
  @override
  void clearCostReport() {
    _serviceUsage.clear();
    Logger.info('Relatório de custos AWS limpo');
  }
  
  @override
  Future<List<Map<String, dynamic>>> checkForUnauthorizedUsage() async {
    final unauthorizedUsage = <Map<String, dynamic>>[];
    
    // Verifica se estamos em modo de desenvolvimento com AWS desabilitado
    if (EnvironmentConfig.isDevelopmentMode && EnvironmentConfig.disableAwsServices) {
      // Se houver qualquer uso registrado, é não autorizado
      _serviceUsage.forEach((key, count) {
        unauthorizedUsage.add({
          'service': key,
          'count': count,
          'estimatedCost': (_costPerService[key] ?? 0.0) * count,
        });
      });
    }
    
    return unauthorizedUsage;
  }
  
  /// Mapeia um serviço e operação para uma chave de custo
  String _mapToCostKey(String service, String operation) {
    switch (service) {
      case 'Cognito':
        return 'Cognito';
      case 'S3':
        if (operation == 'uploadFile' || operation == 'deleteFile') {
          return 'S3_Request';
        } else {
          return 'S3_Storage';
        }
      case 'Lambda':
        return 'Lambda';
      case 'DynamoDB':
        return 'DynamoDB';
      case 'ApiGateway':
        return 'ApiGateway';
      case 'Pinpoint':
        return 'Pinpoint';
      default:
        return 'Other';
    }
  }
}