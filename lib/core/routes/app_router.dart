import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service_local.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/clients/screens/clients_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

/// Provider para o serviço de autenticação local
final authServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

/// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  await authService.init();
  return authService.isAuthenticated;
});

/// Configuração do roteador principal
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Se ainda está carregando, não redireciona
      if (isAuthenticated.isLoading) return null;

      final isLoggedIn = isAuthenticated.value ?? false;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/';

      // Se está na tela de splash, não redireciona
      if (isSplashRoute) return null;

      // Se não está logado e não está nas telas de auth, vai para login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // Se está logado e está nas telas de auth, vai para dashboard
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Tela de splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Telas de autenticação
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Telas principais (requerem autenticação)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Rotas de detalhes
      GoRoute(
        path: '/appointments/:id',
        name: 'appointment-detail',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id']!;
          return AppointmentDetailScreen(appointmentId: appointmentId);
        },
      ),
      GoRoute(
        path: '/clients/:id',
        name: 'client-detail',
        builder: (context, state) {
          final clientId = state.pathParameters['id']!;
          return ClientDetailScreen(clientId: clientId);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

/// Tela de erro para rotas não encontradas
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Voltar ao Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela de detalhes do agendamento (placeholder)
class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendamento #$appointmentId')),
      body: Center(child: Text('Detalhes do agendamento $appointmentId')),
    );
  }
}

/// Tela de detalhes do cliente (placeholder)
class ClientDetailScreen extends StatelessWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cliente #$clientId')),
      body: Center(child: Text('Detalhes do cliente $clientId')),
    );
  }
}
