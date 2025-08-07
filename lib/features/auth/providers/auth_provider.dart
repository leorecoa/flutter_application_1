import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_auth_service.dart';
import '../../../../domain/entities/user.dart';

/// Provider para o estado de autenticação
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(localAuthServiceProvider));
});

/// Estado da autenticação
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier para gerenciar o estado de autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  final LocalAuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isSignedIn = await _authService.isSignedIn();
    if (isSignedIn) {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Falha no login');
        return false;
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro desconhecido');
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name, {
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final success = await _authService.register(
        email,
        password,
        name,
        phone: phone,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro desconhecido');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao fazer logout');
    }
  }

  Future<bool> updateUser(User user) async {
    state = state.copyWith(isLoading: true);

    try {
      final success = await _authService.updateUser(user);
      if (success) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao atualizar usuário',
        );
      }
      return success;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro desconhecido');
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final success = await _authService.changePassword(
        currentPassword,
        newPassword,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro desconhecido');
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final success = await _authService.deleteAccount(password);
      if (success) {
        state = const AuthState();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erro ao deletar conta',
        );
      }
      return success;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro desconhecido');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith();
  }
}
