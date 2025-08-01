import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/appointments/i_appointments_service.dart';
import '../../../core/services/notification_service.dart';
import 'appointment_providers.dart';

/// Controller para gerenciar ações relacionadas à tela de agendamentos
class AppointmentScreenController extends StateNotifier<AsyncValue<void>> {
  final IAppointmentsService _appointmentsService;
  final NotificationService _notificationService;
  final Reader _read;

  AppointmentScreenController(
    this._appointmentsService, 
    this._notificationService,
    this._read
  ) : super(const AsyncValue.data(null));

  /// Atualiza o status de um agendamento
  Future<void> updateAppointmentStatus(String appointmentId, bool isConfirmed) async {
    state = const AsyncValue.loading();
    try {
      final newStatus = isConfirmed 
          ? AppointmentStatus.confirmed 
          : AppointmentStatus.cancelled;
      
      await _appointmentsService.updateAppointmentStatus(appointmentId, newStatus);
      
      // Atualiza o estado local sem precisar buscar todos os dados novamente
      _updateLocalAppointmentState(appointmentId, newStatus);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Exclui um agendamento
  Future<void> deleteAppointment(Appointment appointment) async {
    state = const AsyncValue.loading();
    try {
      await _appointmentsService.deleteAppointment(appointment.id);
      
      // Cancelar notificações associadas
      await _notificationService.cancelAppointmentNotifications(appointment.id);
      
      // Recarregar a lista de agendamentos
      _read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Atualiza o estado local dos providers que contêm o agendamento
  void _updateLocalAppointmentState(String appointmentId, AppointmentStatus newStatus) {
    // Atualiza o estado do provider paginado
    final paginatedNotifier = _read(paginatedAppointmentsProvider.notifier);
    final currentState = _read(paginatedAppointmentsProvider);
    
    final updatedAppointments = currentState.appointments.map((appointment) {
      if (appointment.id == appointmentId) {
        return appointment.copyWith(status: newStatus);
      }
      return appointment;
    }).toList();
    
    paginatedNotifier.updateAppointments(updatedAppointments);
    
    // Invalida outros providers que podem conter este agendamento
    _read(allAppointmentsProvider.notifier).invalidateSelf();
    _read(filteredAppointmentsProvider.notifier).invalidateSelf();
  }
}

/// Provider para o controller da tela de agendamentos
final appointmentScreenControllerProvider = StateNotifierProvider.autoDispose<
    AppointmentScreenController, AsyncValue<void>>((ref) {
  final appointmentsService = ref.watch(appointmentsServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AppointmentScreenController(appointmentsService, notificationService, ref.read);
});