import 'package:go_router/go_router.dart';
import '../middleware/auth_guard.dart';
import '../../features/auth/screens/modern_login.dart';
import '../../features/dashboard/screens/modern_dashboard.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/clients/screens/clients_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/appointments/screens/agendamentos_screen.dart';
import '../../features/admin/screens/admin_clients_screen.dart';
import '../../features/admin/screens/admin_services_screen.dart';
import '../../features/payments/screens/financeiro_screen.dart';
import '../../features/dashboard_financeiro/screens/dashboard_financeiro_screen.dart';
import '../../features/area_cliente/screens/area_cliente_screen.dart';
// import '../../features/recibo_automatico/screens/teste_recibo_screen.dart'; // Removido
import '../../features/admin/screens/admin_settings_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: AuthGuard.redirectLogic,
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const ModernLogin(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const ModernDashboard(),
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
    // Admin Panel Routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/appointments',
      builder: (context, state) => const AgendamentosScreen(),
    ),
    GoRoute(
      path: '/admin/clients',
      builder: (context, state) => const AdminClientsScreen(),
    ),
    GoRoute(
      path: '/admin/services',
      builder: (context, state) => const AdminServicesScreen(),
    ),
    GoRoute(
      path: '/admin/financial',
      builder: (context, state) => const FinanceiroScreen(),
    ),
    GoRoute(
      path: '/admin/settings',
      builder: (context, state) => const AdminSettingsScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard-financeiro',
      builder: (context, state) => const DashboardFinanceiroScreen(),
    ),
    GoRoute(
      path: '/cliente',
      builder: (context, state) => const AreaClienteScreen(),
    ),
    // GoRoute(
    //   path: '/admin/teste-recibo',
    //   builder: (context, state) => const TesteReciboScreen(),
    // ), // Removido
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
  ],
);