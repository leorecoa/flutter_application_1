import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appointments_service_v2.dart';
import '../application/repository_providers.dart';

/// Provider para o serviço de agendamentos V2
final appointmentsServiceV2Provider = Provider<AppointmentsServiceV2>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return AppointmentsServiceV2(repository);
});
