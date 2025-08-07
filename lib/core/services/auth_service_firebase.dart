import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';

/// Implementação do [AuthService] usando o Firebase Authentication.
class AuthServiceFirebase implements AuthService {
  final firebase.FirebaseAuth _firebaseAuth;

  AuthServiceFirebase(this._firebaseAuth);

  @override
  Stream<firebase.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  @override
  firebase.User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<firebase.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseExceptionMessage(e), code: e.code);
    } catch (e) {
      throw AuthException('Ocorreu um erro desconhecido durante o login.');
    }
  }

  @override
  Future<firebase.UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
      }
      return userCredential;
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseExceptionMessage(e), code: e.code);
    } catch (e) {
      throw AuthException('Ocorreu um erro desconhecido durante o registro.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseExceptionMessage(e), code: e.code);
    } catch (e) {
      throw AuthException('Ocorreu um erro desconhecido ao tentar sair.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseExceptionMessage(e), code: e.code);
    } catch (e) {
      throw AuthException('Ocorreu um erro desconhecido ao redefinir a senha.');
    }
  }

  /// Mapeia códigos de erro do Firebase Auth para mensagens amigáveis em português.
  String _mapFirebaseExceptionMessage(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado para este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Contate o suporte.';
      case 'weak-password':
        return 'A senha é muito fraca (deve ter no mínimo 6 caracteres).';
      case 'invalid-credential':
        return 'Credenciais inválidas ou expiradas.';
      default:
        return 'Ocorreu um erro de autenticação. Tente novamente.';
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(firebase.PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(firebase.FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }
}
