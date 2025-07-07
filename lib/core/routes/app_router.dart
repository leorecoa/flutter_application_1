import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../widgets/main_layout.dart';

// Deferred imports for lazy loading
import '../../features/auth/screens/login_screen.dart' deferred as login;
import '../../features/auth/screens/register_screen.dart' deferred as register;
import '../../features/dashboard/screens/dashboard_screen.dart' deferred as dashboard;
import '../../features/reports/screens/reports_screen.dart' deferred as reports;
import '../../features/pix/screens/pix_screen.dart' deferred as pix;
import '../../features/appointments/screens/appointments_screen.dart' deferred as appointments;
import '../../features/settings/screens/settings_screen.dart' deferred as settings;

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: FutureBuilder<void>(
            future: login.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const login.LoginScreen();
              }
              return const _LoadingScreen();
            },
          ),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: FutureBuilder<void>(
            future: register.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const register.RegisterScreen();
              }
              return const _LoadingScreen();
            },
          ),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: dashboard.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const dashboard.DashboardScreen();
                  }
                  return const _LoadingScreen();
                },
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: reports.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const reports.ReportsScreen();
                  }
                  return const _LoadingScreen();
                },
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/pix',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: pix.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const pix.PixScreen();
                  }
                  return const _LoadingScreen();
                },
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: appointments.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const appointments.AppointmentsScreen();
                  }
                  return const _LoadingScreen();
                },
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: FutureBuilder<void>(
                future: settings.loadLibrary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const settings.SettingsScreen();
                  }
                  return const _LoadingScreen();
                },
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Página não encontrada'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Voltar ao Login'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}