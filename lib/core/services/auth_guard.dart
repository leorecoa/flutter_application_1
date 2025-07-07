import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    const publicRoutes = [
      '/',
      '/login',
      '/register',
      '/splash',
      '/manifest.json',
      '/favicon.ico',
    ];

    // Allow all icon paths
    if (path.startsWith('/icons/')) {
      return true;
    }

    // Allow all assets
    if (path.startsWith('/assets/')) {
      return true;
    }

    // Allow service worker and PWA files
    if (path.startsWith('/sw.js') || 
        path.startsWith('/flutter.js') ||
        path.startsWith('/flutter_bootstrap.js') ||
        path.startsWith('/flutter_service_worker.js')) {
      return true;
    }

    return publicRoutes.contains(path);
  }

  static bool _isAuthRoute(String path) {
    const authRoutes = [
      '/login',
      '/register',
    ];

    return authRoutes.contains(path);
  }

  static Future<bool> checkAuthStatus() async {
    try {
      await _authService.init();
      
      // Try to refresh token if we have a refresh token
      if (!_authService.isAuthenticated && _authService.accessToken != null) {
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

  static void logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}