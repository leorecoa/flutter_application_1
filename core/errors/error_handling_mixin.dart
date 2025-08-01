import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/error_handler.dart';
import '../analytics/analytics_service.dart';

/// Mixin para adicionar funcionalidades de tratamento de erros a widgets
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  late final ErrorHandler _errorHandler;
  late final AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();

    // Obtém as dependências necessárias
    final container = ProviderContainer();
    _errorHandler = container.read(errorHandlerProvider);
    _analytics = container.read(analyticsServiceProvider);
  }

  /// Trata um erro e exibe um snackbar com a mensagem
  void handleError(BuildContext context, dynamic error, {String? title}) {
    final errorMessage = _errorHandler.handleError(error);

    // Registra o erro no sistema de logging
    _errorHandler.logError(
      error,
      title ?? 'Erro na tela ${widget.runtimeType}',
      context: {'screen': widget.runtimeType.toString()},
    );

    // Registra o erro no analytics
    _analytics.trackError(
      error.runtimeType.toString(),
      errorMessage,
      parameters: {'screen': widget.runtimeType.toString(), 'title': title},
    );

    // Exibe um snackbar com a mensagem de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Executa uma função assíncrona com tratamento de erro
  Future<T?> runWithErrorHandling<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? errorTitle,
    VoidCallback? onError,
  }) async {
    try {
      return await action();
    } catch (error) {
      handleError(context, error, title: errorTitle);
      onError?.call();
      return null;
    }
  }

  /// Exibe um diálogo de erro
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
