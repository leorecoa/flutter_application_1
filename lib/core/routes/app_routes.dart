import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/screens/analytics_dashboard_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

class AppRoutes {
  // Definição de nomes de rotas para acesso fácil
  static String get dashboard => '/';
  static String get login => '/login';
  static String get signup => '/signup';
  static String get settings => '/settings';
  static String get generatePix => '/pix/generate';
  static String get pixHistory => '/pix/history';
  
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Rota principal
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela Principal')),
        ),
      ),
      
      // Rotas de autenticação
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Login')),
        ),
      ),
      
      GoRoute(
        path: '/signup',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Tela de Cadastro')),
        ),
      ),
      
      // Rotas de agendamentos
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Lista de Agendamentos')),
        ),
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id'];
          return Scaffold(
            body: Center(child: Text('Detalhes do Agendamento $appointmentId')),
          );
        },
      ),
      
      // Rotas de clientes
      GoRoute(
        path: '/clients',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Lista de Clientes')),
        ),
      ),
      
      // Rotas de serviços
      GoRoute(
        path: '/services',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Lista de Serviços')),
        ),
      ),
      
      // Rotas de análise
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      
      // Rotas de notificações
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Rotas de configurações
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Configurações')),
        ),
      ),
      
      // Rotas de perfil
      GoRoute(
        path: '/profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Perfil do Usuário')),
        ),
      ),
      
      // Rotas de PIX
      GoRoute(
        path: '/pix/generate',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Gerar PIX')),
        ),
      ),
      
      GoRoute(
        path: '/pix/history',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Histórico de PIX')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar para o início'),
            ),
          ],
        ),
      ),
    ),
  );
}