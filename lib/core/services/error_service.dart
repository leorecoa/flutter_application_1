import 'package:flutter/material.dart';

class ErrorService {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('connection')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    if (error.toString().contains('timeout')) {
      return 'Tempo limite excedido. Tente novamente.';
    }
    if (error.toString().contains('401')) {
      return 'Sessão expirada. Faça login novamente.';
    }
    if (error.toString().contains('403')) {
      return 'Acesso negado.';
    }
    if (error.toString().contains('404')) {
      return 'Recurso não encontrado.';
    }
    if (error.toString().contains('500')) {
      return 'Erro interno do servidor.';
    }
    return 'Erro inesperado. Tente novamente.';
  }
}