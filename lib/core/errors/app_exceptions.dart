/// Exceção base para todos os erros controlados na aplicação.
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (código: $code)';
}

/// Exceção específica para erros relacionados à autenticação.
class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}
