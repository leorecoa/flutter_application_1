import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/providers/firebase_providers.dart';
import 'package:flutter_application_1/features/auth/application/login_screen_controller.dart';
import 'package:flutter_application_1/features/auth/application/signup_screen_controller.dart';
import 'package:flutter_application_1/features/auth/presentation/state/login_state.dart';
import 'package:flutter_application_1/features/auth/presentation/state/signup_state.dart';

/// Provider para o [LoginScreenController].
///
/// Utiliza `.autoDispose` para que o estado do controller seja resetado
/// quando a tela de login não estiver mais em uso.
final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginScreenController, LoginState>((ref) {
  return LoginScreenController(ref.watch(authServiceProvider));
});

/// Provider para o [SignUpScreenController].
final signUpControllerProvider =
    StateNotifierProvider.autoDispose<SignUpScreenController, SignUpState>(
        (ref) {
  return SignUpScreenController(ref.watch(authServiceProvider));
});

/// Provider que expõe o stream de mudanças de estado de autenticação do Firebase.
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
