import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/multi_region_config.dart';
import 'core/services/api_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/settings/screens/region_selector_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await ApiService().init();
  
  runApp(const ProviderScope(child: AgendaFacilApp()));
}

class AgendaFacilApp extends StatelessWidget {
  const AgendaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgendaFácil SaaS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/settings/region',
      builder: (context, state) => const RegionSelectorScreen(),
    ),
  ],
);