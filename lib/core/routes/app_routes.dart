import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/luxury_dashboard.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/services/screens/services_screen.dart';
import '../../features/clients/screens/clients_screen.dart';
import '../../features/booking/screens/booking_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Dashboard Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const LuxuryDashboard(),
      ),
      
      // Appointments Routes
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      
      // Services Routes
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      
      // Clients Routes
      GoRoute(
        path: '/clients',
        builder: (context, state) => const ClientsScreen(),
      ),
      
      // Public Booking Route
      GoRoute(
        path: '/book/:professionalId',
        builder: (context, state) {
          final professionalId = state.pathParameters['professionalId']!;
          return BookingScreen(professionalId: professionalId);
        },
      ),
    ],
  );
}