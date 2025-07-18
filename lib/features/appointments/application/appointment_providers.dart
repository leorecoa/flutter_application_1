import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service_v2.dart';

/// Provider para o serviço de agendamentos
final appointmentsServiceProvider = Provider<AppointmentsServiceV2>((ref) {
  return AppointmentsServiceV2();
});

/// Provider para lista de agendamentos
final appointmentsProvider = FutureProvider.family<List<Appointment>, DateTime?>((ref, date) async {
  final service = ref.watch(appointmentsServiceProvider);
  final appointments = await service.getAppointmentsList();
  
  // Se não houver data selecionada, retorna todos os agendamentos
  if (date == null) {
    return appointments;
  }
  
  // Filtra agendamentos pela data selecionada
  return appointments.where((appointment) {
    return appointment.dateTime.year == date.year &&
           appointment.dateTime.month == date.month &&
           appointment.dateTime.day == date.day;
  }).toList();
});