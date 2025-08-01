import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../errors/app_exceptions.dart';

/// Provider para o serviço de tratamento de erros
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandlerImpl();
});

/// Interface para o serviço de tratamento de erros
abstract class ErrorHandler {
  /// Trata um erro e retorna uma mensagem amigável
  String handleError(dynamic error);
  
  /// Registra um erro no sistema de logging
  void logError(dynamic error, String message, {Map<String, dynamic>? context});
  
  /// Trata um erro de validação
  String handleValidationError(ValidationException error);
  
  /// Trata um erro de rede
  String handleNetworkError(NetworkException error);
  
  /// Trata um erro de autenticação
  String handleAuthError(AuthException error);
  
  /// Trata um erro de servidor
  String handleServerError(ServerException error);
}

/// Implementação do serviço de tratamento de erros
class ErrorHandlerImpl implements ErrorHandler {
  @override
  String handleError(dynamic error) {
    if (error is ValidationException) {
      return handleValidationError(error);
    } else if (error is NetworkException) {
      return handleNetworkError(error);
    } else if (error is AuthException) {
      return handleAuthError(error);
    } else if (error is ServerException) {
      return handleServerError(error);
    } else if (error is UnauthorizedException) {
      return 'Acesso negado: ${error.message}';
    } else if (error is NotFoundException) {
      return 'Recurso não encontrado: ${error.message}';
    } else if (error is UseCaseException) {
      return 'Erro na operação: ${error.message}';
    } else if (error is String) {
      return error;
    } else {
      return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    }
  }
  
  @override
  void logError(dynamic error, String message, {Map<String, dynamic>? context}) {
    final errorType = _getErrorType(error);
    final errorMessage = error is AppException ? error.message : error.toString();
    
    Logger.error(
      message,
      error: error,
      context: {
        'errorType': errorType,
        'errorMessage': errorMessage,
        ...?context,
      },
    );
  }
  
  @override
  String handleValidationError(ValidationException error) {
    return 'Erro de validação: ${error.message}';
  }
  
  @override
  String handleNetworkError(NetworkException error) {
    switch (error.type) {
      case NetworkErrorType.noConnection:
        return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
      case NetworkErrorType.timeout:
        return 'A operação excedeu o tempo limite. Por favor, tente novamente.';
      case NetworkErrorType.serverUnreachable:
        return 'Não foi possível conectar ao servidor. Por favor, tente novamente mais tarde.';
      default:
        return 'Erro de rede: ${error.message}';
    }
  }
  
  @override
  String handleAuthError(AuthException error) {
    switch (error.type) {
      case AuthErrorType.invalidCredentials:
        return 'Credenciais inválidas. Verifique seu e-mail e senha.';
      case AuthErrorType.userNotFound:
        return 'Usuário não encontrado.';
      case AuthErrorType.sessionExpired:
        return 'Sua sessão expirou. Por favor, faça login novamente.';
      default:
        return 'Erro de autenticação: ${error.message}';
    }
  }
  
  @override
  String handleServerError(ServerException error) {
    switch (error.statusCode) {
      case 400:
        return 'Requisição inválida. Por favor, verifique os dados enviados.';
      case 401:
        return 'Não autorizado. Por favor, faça login novamente.';
      case 403:
        return 'Acesso negado. Você não tem permissão para acessar este recurso.';
      case 404:
        return 'Recurso não encontrado.';
      case 500:
        return 'Erro interno do servidor. Por favor, tente novamente mais tarde.';
      default:
        return 'Erro do servidor: ${error.message}';
    }
  }
  
  /// Obtém o tipo de erro para logging
  String _getErrorType(dynamic error) {
    if (error is ValidationException) return 'validation_error';
    if (error is NetworkException) return 'network_error';
    if (error is AuthException) return 'auth_error';
    if (error is ServerException) return 'server_error';
    if (error is UnauthorizedException) return 'unauthorized_error';
    if (error is NotFoundException) return 'not_found_error';
    if (error is UseCaseException) return 'use_case_error';
    return 'unknown_error';
  }
}