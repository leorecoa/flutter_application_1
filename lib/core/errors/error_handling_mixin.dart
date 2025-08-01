import 'package:flutter/material.dart';

/// Mixin para tratamento padronizado de erros
mixin ErrorHandlingMixin {
  /// Registra um erro e retorna uma mensagem amigável
  String handleError(dynamic error, {String? context}) {
    // Aqui você pode adicionar lógica para registrar o erro em um serviço de monitoramento
    debugPrint('Erro${context != null ? " em $context" : ""}: $error');

    // Retorna uma mensagem amigável para o usuário
    return 'Ocorreu um erro${context != null ? " ao $context" : ""}. Por favor, tente novamente.';
  }

  /// Executa uma operação assíncrona com tratamento de erro
  Future<void> handleAsyncOperation(
    Future<void> Function() operation, {
    String? context,
    String? successMessage,
  }) async {
    try {
      await operation();
      if (successMessage != null) {
        // Aqui você pode mostrar uma mensagem de sucesso
        debugPrint(successMessage);
      }
    } catch (error) {
      final errorMessage = handleError(error, context: context);
      debugPrint(errorMessage);
      // Aqui você pode mostrar o erro para o usuário
    }
  }
}
