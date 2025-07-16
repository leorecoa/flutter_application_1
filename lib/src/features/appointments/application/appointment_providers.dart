import 'package:agendafacil/src/features/appointments/data/appointment_model.dart';
import 'package:agendafacil/src/features/appointments/data/appointment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provedor para a implementação do repositório
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl();
});

// Provedor que busca os agendamentos para um dia específico
// A família permite passar um parâmetro (a data) para o provedor
final appointmentsProvider =
    FutureProvider.family<List<Appointment>, DateTime>((ref, date) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAppointments(date);
});
