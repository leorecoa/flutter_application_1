import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final bool isSignedIn;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? userAttributes;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isSignedIn = false,
    this.user,
    this.userAttributes,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    Map<String, dynamic>? user,
    Map<String, dynamic>? userAttributes,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      userAttributes: userAttributes ?? this.userAttributes,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isSignedIn = await AuthService().isSignedIn();
      if (isSignedIn) {
        final user = AuthService.getCurrentUser();
        final attributes = <String, dynamic>{'email': 'mock@email.com'};
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: user,
          userAttributes: attributes,
        );
      } else {
        state = state.copyWith(isLoading: false, isSignedIn: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService().signIn(email, password);
      
      if (result['success'] == true) {
        final user = AuthService.getCurrentUser();
        final attributes = <String, dynamic>{'email': email};
        state = state.copyWith(
          isLoading: false,
          isSignedIn: true,
          user: user,
          userAttributes: attributes,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // await AuthService().signOut(); // Mock implementation
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});