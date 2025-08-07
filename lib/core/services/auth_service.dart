import 'package:firebase_auth/firebase_auth.dart' as firebase;

/// Interface para o serviço de autenticação.
///
/// Abstrai a implementação do backend (Firebase Auth) para permitir
/// testes e futuras migrações com mais facilidade, seguindo os princípios
/// da Clean Architecture.
abstract class AuthService {
  /// Retorna um Stream que notifica sobre mudanças no estado de autenticação do usuário.
  ///
  /// Ideal para ser usado em um [StreamProvider] para reagir a logins e logouts.
  Stream<firebase.User?> get authStateChanges;

  /// Retorna o usuário atualmente autenticado, ou null se não houver.
  firebase.User? get currentUser;

  /// Realiza o login de um usuário com e-mail e senha.
  ///
  /// Lança uma [AuthException] em caso de falha.
  Future<firebase.UserCredential> signIn({
    required String email,
    required String password,
  });

  /// Registra um novo usuário com e-mail e senha.
  ///
  /// Opcionalmente, pode receber um [displayName] para o perfil.
  /// Lança uma [AuthException] em caso de falha.
  Future<firebase.UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Realiza o logout do usuário atual.
  Future<void> signOut();

  /// Envia um e-mail para redefinição de senha.
  ///
  /// Lança uma [AuthException] em caso de falha.
  Future<void> sendPasswordResetEmail({required String email});

  /// Inicia o fluxo de verificação por telefone, enviando um código SMS.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(firebase.PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(firebase.FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });
}
