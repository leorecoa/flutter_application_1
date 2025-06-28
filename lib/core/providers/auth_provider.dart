import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../services/amplify_service.dart';

class AuthState {
  final bool isLoading;
  final bool isSignedIn;
  final AuthUser? user;
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
    AuthUser? user,
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
      final isSignedIn = await AmplifyService.isSignedIn();
      if (isSignedIn) {
        final user = await AmplifyService.getCurrentUser();
        final attributes = await AmplifyService.getUserAttributes();
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
      final result = await AmplifyService.signIn(email, password);
      
      if (result.isSignedIn) {
        final user = await AmplifyService.getCurrentUser();
        final attributes = await AmplifyService.getUserAttributes();
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
      await AmplifyService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});