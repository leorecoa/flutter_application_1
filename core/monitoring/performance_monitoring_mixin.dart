import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../analytics/analytics_service.dart';
import '../tenant/tenant_context.dart';
import '../errors/error_handler.dart';

/// Mixin para adicionar funcionalidades de monitoramento de desempenho a widgets
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  late final AnalyticsService _analytics;
  late final TenantContext _tenantContext;
  late final ErrorHandler _errorHandler;
  late final String _screenName;
  late final Stopwatch _screenLoadTimer;

  @override
  void initState() {
    super.initState();
    _screenLoadTimer = Stopwatch()..start();

    // Obtém as dependências necessárias
    final container = ProviderContainer();
    _analytics = container.read(analyticsServiceProvider);
    _tenantContext = container.read(tenantContextProvider);
    _errorHandler = container.read(errorHandlerProvider);

    // Define o nome da tela com base no widget
    _screenName = widget.runtimeType.toString();

    // Registra o início da visualização da tela
    _trackScreenView();

    // Adiciona listener para mudanças de ciclo de vida
    WidgetsBinding.instance.addObserver(
      _LifecycleObserver(onResume: _onResume, onPause: _onPause),
    );
  }

  @override
  void dispose() {
    // Registra o tempo total de visualização da tela
    _trackScreenExit();
    super.dispose();
  }

  /// Registra a visualização da tela
  void _trackScreenView() {
    try {
      final tenantId = _tenantContext.currentTenant?.id;
      final userId = _tenantContext.currentUser?.id;

      _analytics.trackScreenView(
        _screenName,
        parameters: {'tenantId': tenantId, 'userId': userId},
      );

      Logger.info(
        'Tela visualizada',
        context: {
          'screenName': _screenName,
          'tenantId': tenantId,
          'userId': userId,
        },
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar visualização de tela');
    }
  }

  /// Registra a saída da tela
  void _trackScreenExit() {
    try {
      final loadTime = _screenLoadTimer.elapsedMilliseconds;

      _analytics.trackEvent(
        'screen_exit',
        parameters: {'screenName': _screenName, 'timeSpentMs': loadTime},
      );

      Logger.info(
        'Saída de tela',
        context: {'screenName': _screenName, 'timeSpentMs': loadTime},
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar saída de tela');
    }
  }

  /// Chamado quando o aplicativo é retomado
  void _onResume() {
    try {
      _analytics.trackEvent(
        'screen_resumed',
        parameters: {'screenName': _screenName},
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar retomada de tela');
    }
  }

  /// Chamado quando o aplicativo é pausado
  void _onPause() {
    try {
      _analytics.trackEvent(
        'screen_paused',
        parameters: {'screenName': _screenName},
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar pausa de tela');
    }
  }

  /// Registra uma ação do usuário
  void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    try {
      _analytics.trackUserAction(
        action,
        parameters: {'screenName': _screenName, ...?parameters},
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar ação do usuário');
    }
  }

  /// Registra um erro
  void trackError(
    String errorType,
    String errorMessage, {
    Map<String, dynamic>? parameters,
  }) {
    try {
      _analytics.trackError(
        errorType,
        errorMessage,
        parameters: {'screenName': _screenName, ...?parameters},
      );
    } catch (e) {
      _errorHandler.logError(e, 'Erro ao registrar erro');
    }
  }
}

/// Observer para monitorar mudanças no ciclo de vida do aplicativo
class _LifecycleObserver extends WidgetsBindingObserver {
  _LifecycleObserver({required this.onResume, required this.onPause});

  final VoidCallback onResume;
  final VoidCallback onPause;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    } else if (state == AppLifecycleState.paused) {
      onPause();
    }
  }
}
