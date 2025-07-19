import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Classe utilitária para otimizar o desempenho do aplicativo
class PerformanceOptimizer {
  /// Singleton instance
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  
  /// Construtor de fábrica para retornar a instância singleton
  factory PerformanceOptimizer() => _instance;
  
  /// Construtor interno
  PerformanceOptimizer._internal();
  
  /// Métricas de desempenho
  final Map<String, PerformanceMetric> _metrics = {};
  
  /// Inicia a medição de desempenho para uma operação
  void startMeasure(String operationName) {
    _metrics[operationName] = PerformanceMetric(
      name: operationName,
      startTime: DateTime.now(),
    );
  }
  
  /// Finaliza a medição de desempenho para uma operação
  void endMeasure(String operationName) {
    if (_metrics.containsKey(operationName)) {
      final metric = _metrics[operationName]!;
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      
      if (kDebugMode) {
        print('Operação "$operationName" levou ${metric.duration!.inMilliseconds}ms');
      }
    }
  }
  
  /// Retorna todas as métricas de desempenho
  List<PerformanceMetric> getAllMetrics() {
    return _metrics.values.toList();
  }
  
  /// Limpa todas as métricas de desempenho
  void clearMetrics() {
    _metrics.clear();
  }
  
  /// Widget para medir o desempenho de renderização
  Widget measureBuildTime(String widgetName, Widget child) {
    return _PerformanceMeasureWidget(
      widgetName: widgetName,
      child: child,
    );
  }
  
  /// Otimiza uma lista para melhor desempenho
  List<T> optimizeList<T>(List<T> list, {int maxItems = 100}) {
    if (list.length <= maxItems) {
      return list;
    }
    
    // Se a lista for muito grande, retorna apenas os primeiros itens
    return list.sublist(0, maxItems);
  }
  
  /// Verifica se um widget deve ser reconstruído com base em suas propriedades
  bool shouldRebuild(Map<String, dynamic> oldProps, Map<String, dynamic> newProps) {
    for (final key in oldProps.keys) {
      if (newProps.containsKey(key) && oldProps[key] != newProps[key]) {
        return true;
      }
    }
    return false;
  }
}

/// Widget para medir o tempo de construção
class _PerformanceMeasureWidget extends StatefulWidget {
  final String widgetName;
  final Widget child;
  
  const _PerformanceMeasureWidget({
    required this.widgetName,
    required this.child,
  });
  
  @override
  _PerformanceMeasureWidgetState createState() => _PerformanceMeasureWidgetState();
}

class _PerformanceMeasureWidgetState extends State<_PerformanceMeasureWidget> {
  late DateTime _startTime;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duration = DateTime.now().difference(_startTime);
      if (kDebugMode) {
        print('Widget "${widget.widgetName}" construído em ${duration.inMilliseconds}ms');
      }
    });
    
    return widget.child;
  }
}

/// Classe para armazenar métricas de desempenho
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;
  
  PerformanceMetric({
    required this.name,
    required this.startTime,
  });
  
  @override
  String toString() {
    return 'PerformanceMetric{name: $name, duration: ${duration?.inMilliseconds}ms}';
  }
}