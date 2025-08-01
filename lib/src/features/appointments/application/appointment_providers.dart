import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/appointment_model.dart';

/// Implementação temporária do repositório
class AppointmentRepositoryImpl {
  Future<List<Appointment>> getAppointments({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    // Implementação temporária
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'service1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        clientName: 'João Silva',
        clientPhone: '11999999999',
        serviceName: 'Corte de Cabelo',
        price: 50.0,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

/// Provider para o repositório de agendamentos
final appointmentRepositoryProvider = Provider<AppointmentRepositoryImpl>((
  ref,
) {
  return AppointmentRepositoryImpl();
});

/// Provider para buscar todos os agendamentos
final allAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final repository = ref.read(appointmentRepositoryProvider);
  return await repository.getAppointments();
});

/// Provider para buscar agendamentos paginados
final paginatedAppointmentsProvider =
    FutureProvider.family<List<Appointment>, Map<String, dynamic>>((
      ref,
      filters,
    ) async {
      final repository = ref.read(appointmentRepositoryProvider);
      return await repository.getAppointments(filters: filters);
    });
