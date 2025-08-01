import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço para rastreamento de analytics
class AnalyticsService {
  /// Provider para o serviço de analytics
  static final provider = Provider<AnalyticsService>((ref) {
    return AnalyticsService();
  });
  
  /// Rastreia um evento
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 50));
    print('Analytics Event: $eventName, Parameters: $parameters');
  }
}