import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/error_handler.dart';

/// Mixin para tratamento de erros em widgets
mixin ErrorHandlingMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Executa uma função assíncrona com tratamento de erros
  Future<void> handleAsyncOperation(
    Future<void> Function() operation, {
    String? successMessage,
    bool showLoadingIndicator = true,
    VoidCallback? onSuccess,
  }) async {
    if (showLoadingIndicator) {
      _showLoadingDialog();
    }

    try {
      await operation();

      if (!mounted) return;

      if (showLoadingIndicator) {
        Navigator.of(context).pop(); // Remove loading dialog
      }

      if (successMessage != null) {
        _showSuccessSnackBar(successMessage);
      }

      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      if (showLoadingIndicator) {
        Navigator.of(context).pop(); // Remove loading dialog
      }

      ErrorHandler.logError(e, stackTrace);
      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  /// Exibe um diálogo de carregamento
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Exibe um SnackBar de sucesso
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
