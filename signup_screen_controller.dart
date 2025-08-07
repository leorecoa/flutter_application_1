import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_application_1/features/auth/presentation/state/signup_state.dart';

/// Controller for the sign-up screen.
///
/// Manages the UI state and interacts with the [AuthService] to
/// perform user registration.
class SignUpScreenController extends StateNotifier<SignUpState> {
  final AuthService _authService;

  SignUpScreenController(this._authService)
    : super(const SignUpState.initial());

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const SignUpState.loading();
    try {
      await _authService.signUp(
        displayName: name,
        email: email,
        password: password,
      );
      state = const SignUpState.success();
    } on AuthException catch (e) {
      state = SignUpState.error(e.message);
    }
  }
}
