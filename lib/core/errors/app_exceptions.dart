/// Exceção base para a aplicação
abstract class AppException implements Exception {
  /// Mensagem de erro
  final String message;
  
  /// Construtor
  AppException(this.message);
  
  @override
  String toString() => message;
}

/// Exceção para erros de validação
class ValidationException extends AppException {
  /// Construtor
  ValidationException(String message) : super(message);
}

/// Exceção para erros de autenticação
class UnauthorizedException extends AppException {
  /// Construtor
  UnauthorizedException(String message) : super(message);
}

/// Exceção para recursos não encontrados
class NotFoundException extends AppException {
  /// Construtor
  NotFoundException(String message) : super(message);
}

/// Exceção para erros de repositório
class RepositoryException extends AppException {
  /// Construtor
  RepositoryException(String message) : super(message);
}

/// Exceção para erros de caso de uso
class UseCaseException extends AppException {
  /// Construtor
  UseCaseException(String message) : super(message);
}

/// Exceção para erros de serviço
class ServiceException extends AppException {
  /// Construtor
  ServiceException(String message) : super(message);
}

/// Exceção para erros de rede
class NetworkException extends AppException {
  /// Código de status HTTP (opcional)
  final int? statusCode;
  
  /// Construtor
  NetworkException(String message, {this.statusCode}) : super(message);
}

/// Exceção para erros de cache
class CacheException extends AppException {
  /// Construtor
  CacheException(String message) : super(message);
}

/// Exceção para erros de tenant
class TenantException extends AppException {
  /// Construtor
  TenantException(String message) : super(message);
}

/// Exceção para erros de configuração
class ConfigurationException extends AppException {
  /// Construtor
  ConfigurationException(String message) : super(message);
}