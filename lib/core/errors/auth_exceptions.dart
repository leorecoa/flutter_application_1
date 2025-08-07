/// Exceção base para erros de autenticação.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Lançada quando o usuário não é encontrado.
class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('Usuário não encontrado.');
}

/// Lançada quando a senha ou o usuário estão incorretos.
class NotAuthorizedException extends AuthException {
  NotAuthorizedException() : super('Email ou senha inválidos.');
}
