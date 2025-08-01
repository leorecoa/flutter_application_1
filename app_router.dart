import 'package:flutter_application_1/src/features/appointments/presentation/appointment_detail_screen.dart';
import 'package:flutter_application_1/src/features/appointments/presentation/appointments_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/appointments',
    routes: [
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
      // TODO: Adicionar outras rotas principais aqui (ex: /login, /dashboard)
    ],
  );
});
