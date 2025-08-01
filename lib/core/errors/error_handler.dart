import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exceptions.dart';

/// Classe para gerenciar o tratamento de erros na aplicação
class ErrorHandler {
  /// Converte exceções em mensagens amigáveis para o usuário
  static String getUserFriendlyMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is UseCaseException) {
      return error.message;
    } else if (error is RepositoryException) {
      return 'Erro ao acessar os dados: ${error.message}';
    } else if (error is ApiException) {
      return _getApiErrorMessage(error);
    } else if (error is AuthException) {
      return 'Erro de autenticação: ${error.message}';
    } else if (error is NetworkException) {
      return 'Erro de conexão: Verifique sua internet e tente novamente';
    } else if (error is TenantException) {
      return 'Erro de acesso: ${error.message}';
    } else {
      return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    }
  }
  
  /// Obtém mensagem específica para erros de API
  static String _getApiErrorMessage(ApiException error) {
    switch (error.statusCode) {
      case 400:
        return 'Requisição inválida: ${error.message}';
      case 401:
        return 'Não autorizado: Faça login novamente';
      case 403:
        return 'Acesso negado: Você não tem permissão para esta operação';
      case 404:
        return 'Recurso não encontrado';
      case 409:
        return 'Conflito de dados: ${error.message}';
      case 422:
        return 'Dados inválidos: ${error.message}';
      case 429:
        return 'Muitas requisições. Tente novamente em alguns instantes';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Erro no servidor. Tente novamente mais tarde';
      default:
        return 'Erro na comunicação com o servidor: ${error.message}';
    }
  }
  
  /// Exibe um SnackBar com a mensagem de erro
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
  
  /// Registra o erro para análise posterior
  static void logError(dynamic error, StackTrace? stackTrace) {
    // Implementar logging para CloudWatch ou outro serviço
    debugPrint('ERROR: ${error.toString()}');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: ${stackTrace.toString()}');
    }
  }
}

/// Provider para o ErrorHandler
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});