import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service_v2.dart';
import 'paginated_appointments_notifier.dart';
import 'paginated_appointments_state.dart';

import '../../../core/services/appointments/i_appointments_service.dart';
import '../../../core/services/appointments/appointments_service.dart';
import '../../../core/services/api_service_provider.dart';

/// Provider para o serviço de agendamentos
///
/// Fornece uma implementação da interface IAppointmentsService.
/// Em testes, pode ser facilmente substituído por um mock.
final appointmentsServiceProvider = Provider<IAppointmentsService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AppointmentsService(apiService);
});

/// Provider para gerenciar os filtros de agendamentos
final appointmentFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider para o termo de busca
final searchTermProvider = StateProvider<String>((ref) => '');

/// Provider para todos os agendamentos (sem filtros)
final allAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final service = ref.watch(appointmentsServiceProvider);
  final response = await service.getAppointmentsList();
  return response.items;
});

/// Provider para agendamentos filtrados (sem paginação)
final filteredAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final service = ref.watch(appointmentsServiceProvider);
  final filters = ref.watch(appointmentFiltersProvider);
  final searchTerm = ref.watch(searchTermProvider);
  
  final response = await service.getAppointmentsList(
    filters: filters,
    searchTerm: searchTerm.isNotEmpty ? searchTerm : null,
  );
  return response.items;
});

/// Provider para agendamentos paginados
final paginatedAppointmentsProvider = StateNotifierProvider.autoDispose<
    PaginatedAppointmentsNotifier, PaginatedAppointmentsState>((ref) {
  final service = ref.watch(appointmentsServiceProvider);
  final filters = ref.watch(appointmentFiltersProvider);
  final searchTerm = ref.watch(searchTermProvider);
  
  // Adicionar termo de busca aos filtros se não estiver vazio
  final updatedFilters = Map<String, dynamic>.from(filters);
  if (searchTerm.isNotEmpty) {
    updatedFilters['search'] = searchTerm;
  }
  
  return PaginatedAppointmentsNotifier(service, updatedFilters);
});

/// Provider para agendamentos de uma data específica
final appointmentsProvider = FutureProvider.family<List<Appointment>, DateTime?>((ref, date) async {
  final service = ref.watch(appointmentsServiceProvider);
  final response = await service.getAppointmentsList();
  final appointments = response.items;
  
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