import 'package:go_router/go_router.dart';
import '../../features/auth/screens/amplify_login_screen.dart';
import '../../features/dashboard/screens/luxury_dashboard.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/clients/screens/clients_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/reports/screens/reports_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AmplifyLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const LuxuryDashboard(),
    ),
    GoRoute(
      path: '/appointments',
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(
      path: '/clients',
      builder: (context, state) => const ClientsScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);