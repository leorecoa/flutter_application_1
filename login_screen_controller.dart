import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_application_1/features/auth/presentation/state/login_state.dart';

/// Controller para a tela de login.
///
/// Gerencia o estado da UI e interage com o [AuthService] para
/// realizar a autenticação do usuário.
class LoginScreenController extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginScreenController(this._authService) : super(const LoginState.initial());

  Future<void> signIn(String email, String password) async {
    state = const LoginState.loading();
    try {
      await _authService.signIn(email: email, password: password);
      state = const LoginState.success();
    } on AuthException catch (e) {
      state = LoginState.error(e.message);
    }
  }
}
