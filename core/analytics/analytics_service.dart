import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../tenant/tenant_context.dart';
import '../config/environment_config.dart';

/// Provider para o serviço de analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final tenantContext = ref.watch(tenantContextProvider);
  return AnalyticsService(tenantContext);
});

/// Serviço para rastrear eventos de analytics na aplicação
class AnalyticsService {
  AnalyticsService(this._tenantContext);

  final TenantContext _tenantContext;

  /// Rastreia um evento de analytics
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final tenantId = _tenantContext.currentTenant?.id;
      final userId = _tenantContext.currentUser?.id;

      // Adiciona informações do tenant e usuário aos parâmetros
      final enrichedParams = {
        ...?parameters,
        'tenantId': tenantId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Registra o evento no logger para debug
      Logger.info('Analytics event: $eventName', context: enrichedParams);

      // Envia para o serviço de analytics apenas em produção ou se explicitamente habilitado
      if (EnvironmentConfig.shouldTrackAnalytics) {
        await _sendToAmplifyAnalytics(eventName, enrichedParams);
      }
    } catch (e) {
      Logger.error('Erro ao rastrear evento de analytics', error: e);
    }
  }

  /// Envia evento para o Amplify Analytics
  Future<void> _sendToAmplifyAnalytics(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    // Em desenvolvimento, esta função não faz nada para economizar custos
    // Em produção, implementaria:
    // await Amplify.Analytics.recordEvent(
    //   name: eventName,
    //   properties: parameters,
    // );
  }

  /// Rastreia uma visualização de tela
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      'screen_view',
      parameters: {'screen_name': screenName, ...?parameters},
    );
  }

  /// Rastreia uma ação do usuário
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      'user_action',
      parameters: {'action': action, ...?parameters},
    );
  }

  /// Rastreia um erro
  Future<void> trackError(
    String errorType,
    String errorMessage, {
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      'error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        ...?parameters,
      },
    );
  }
}
