import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/pix/screens/generate_pix_screen.dart';
import '../../features/pix/screens/pix_history_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String generatePix = '/generate-pix';
  static const String pixHistory = '/pix-history';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: generatePix,
        name: 'generate-pix',
        builder: (context, state) => const GeneratePixScreen(),
      ),
      GoRoute(
        path: pixHistory,
        name: 'pix-history',
        builder: (context, state) => const PixHistoryScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página não encontrada: ${state.uri.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(login),
              child: const Text('Voltar ao Login'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // Redirecionar para dashboard se já estiver autenticado
      // Implementação futura com verificação de autenticação
      return null;
    },
  );
}
