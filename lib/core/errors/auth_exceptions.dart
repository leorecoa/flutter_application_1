/// Exceções relacionadas à autenticação
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

/// Exceção para credenciais inválidas
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String message = 'Credenciais inválidas'])
    : super(message, code: 'INVALID_CREDENTIALS');
}

/// Exceção para usuário não encontrado
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String message = 'Usuário não encontrado'])
    : super(message, code: 'USER_NOT_FOUND');
}

/// Exceção para token inválido
class InvalidTokenException extends AuthException {
  const InvalidTokenException([String message = 'Token inválido'])
    : super(message, code: 'INVALID_TOKEN');
}

/// Exceção para token expirado
class TokenExpiredException extends AuthException {
  const TokenExpiredException([String message = 'Token expirado'])
    : super(message, code: 'TOKEN_EXPIRED');
}

/// Exceção para conta desabilitada
class AccountDisabledException extends AuthException {
  const AccountDisabledException([String message = 'Conta desabilitada'])
    : super(message, code: 'ACCOUNT_DISABLED');
}
