import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/application/auth_providers.dart';
import 'package:flutter_application_1/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application_1/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_application_1/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter_application_1/src/features/appointments/presentation/appointment_detail_screen.dart';
import 'package:flutter_application_1/src/features/appointments/presentation/appointments_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Observa o estado de autenticação para o redirecionamento.
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/login',
    // O refreshListenable garante que o GoRouter reavalie a rota
    // sempre que o estado de autenticação mudar.
    refreshListenable: GoRouterRefreshStream(authState.asStream()),
    redirect: (context, state) {
      // Usa o valor mais recente do stream para saber se o usuário está logado.
      final isLoggedIn = authState.value != null;

      // Lista de rotas públicas que não exigem login.
      final publicRoutes = ['/login', '/signup'];

      // Verifica se a rota atual é pública.
      final isGoingToPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Se não estiver logado e tentando acessar uma rota protegida,
      // redireciona para a tela de login.
      if (!isLoggedIn && !isGoingToPublicRoute) {
        return '/login';
      }

      // Se estiver logado e tentando acessar uma rota pública,
      // redireciona para a tela principal (dashboard).
      if (isLoggedIn && isGoingToPublicRoute) {
        return '/';
      }

      // Nenhum redirecionamento necessário, permite a navegação.
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsScreen(),
        routes: [
          GoRoute(
            path: ':appointmentId', // ex: /appointments/123
            builder: (context, state) {
              final appointmentId = state.pathParameters['appointmentId']!;
              return AppointmentDetailScreen(appointmentId: appointmentId);
            },
          ),
        ],
      ),
    ],
  );
});

// Classe auxiliar para converter um Stream em um Listenable, necessário para o GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
