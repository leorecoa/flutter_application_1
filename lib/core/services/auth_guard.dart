import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class AuthGuard {
  static final AuthService _authService = AuthService();

  static String? redirectLogic(BuildContext context, GoRouterState state) {
    final isAuthenticated = _authService.isAuthenticated;
    final isPublicRoute = _isPublicRoute(state.uri.path);
    
    // Allow access to public routes
    if (isPublicRoute) {
      return null;
    }

    // Redirect unauthenticated users to login
    if (!isAuthenticated) {
      return '/login';
    }

    // Redirect authenticated users away from auth pages
    if (isAuthenticated && _isAuthRoute(state.uri.path)) {
      return '/dashboard';
    }

    return null;
  }

  static bool _isPublicRoute(String path) {
    // Use the predefined public routes from constants
    if (AppConstants.publicRoutes.contains(path)) {
      return true;
    }

    // Allow all icon paths (PWA requirements)
    if (path.startsWith('/icons/') || path.contains('Icon-')) {
      return true;
    }

    // Allow all assets (PWA requirements)
    if (path.startsWith('/assets/')) {
      return true;
    }

    // Allow service worker and PWA files (PWA requirements)
    const pwaFiles = [
      '/sw.js',
      '/flutter.js',
      '/flutter_bootstrap.js', 
      '/flutter_service_worker.js',
      '/main.dart.js',
      '/version.json',
    ];
    
    if (pwaFiles.any((file) => path.startsWith(file))) {
      return true;
    }

    // Allow canvaskit files
    if (path.startsWith('/canvaskit/')) {
      return true;
    }

    return false;
  }

  static bool _isAuthRoute(String path) {
    const authRoutes = [
      '/login',
      '/register',
      '/forgot-password',
      '/reset-password',
    ];

    return authRoutes.contains(path);
  }

  static Future<bool> checkAuthStatus() async {
    try {
      await _authService.init();
      
      // Try to refresh token if we have one but user is not authenticated
      if (!_authService.isAuthenticated && _authService.refreshToken != null) {
        return await _authService.refreshAccessToken();
      }
      
      return _authService.isAuthenticated;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  static Future<void> requireAuth(BuildContext context) async {
    final isAuthenticated = await checkAuthStatus();
    
    if (!isAuthenticated && context.mounted) {
      context.go('/login');
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      await _authService.logout();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  // Método para verificar se o usuário tem permissão para acessar uma rota específica
  static bool canAccessRoute(String route) {
    if (_isPublicRoute(route)) {
      return true;
    }
    
    return _authService.isAuthenticated;
  }

  // Método para obter informações do usuário atual
  static Map<String, dynamic>? getCurrentUserInfo() {
    if (_authService.isAuthenticated && _authService.currentUser != null) {
      return {
        'id': _authService.currentUser!.id,
        'name': _authService.currentUser!.name,
        'email': _authService.currentUser!.email,
        'phone': _authService.currentUser!.phone,
      };
    }
    return null;
  }
}