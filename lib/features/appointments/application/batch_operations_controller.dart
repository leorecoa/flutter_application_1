import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/appointments/i_appointments_service.dart';
import '../../../core/services/notification_service.dart';
import 'appointment_providers.dart';

/// Resultado de uma operação em lote
class BatchOperationResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;

  const BatchOperationResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });
}

/// Controller para gerenciar operações em lote de agendamentos
class BatchOperationsController extends StateNotifier<AsyncValue<BatchOperationResult>> {
  final IAppointmentsService _appointmentsService;
  final NotificationService _notificationService;
  final Reader _read;

  BatchOperationsController(
    this._appointmentsService,
    this._notificationService,
    this._read,
  ) : super(const AsyncValue.data(
      BatchOperationResult(successCount: 0, failureCount: 0, errors: []),
    ));

  /// Cancela múltiplos agendamentos em lote
  Future<BatchOperationResult> cancelAppointments(List<Appointment> appointments) async {
    state = const AsyncValue.loading();
    
    try {
      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      // Processa todos os cancelamentos em paralelo para maior eficiência
      await Future.wait(appointments.map((appointment) async {
        try {
          await _appointmentsService.updateAppointmentStatus(
            appointment.id, 
            AppointmentStatus.cancelled,
          );
          
          // Cancelar notificações associadas
          await _notificationService.cancelAppointmentNotifications(appointment.id);
          
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Erro ao cancelar agendamento de ${appointment.clientName}: $e');
        }
      }));

      // Recarregar a lista de agendamentos se houver sucesso
      if (successCount > 0) {
        _read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        _read(allAppointmentsProvider.notifier).invalidateSelf();
      }

      final result = BatchOperationResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
      
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return BatchOperationResult(
        successCount: 0,
        failureCount: appointments.length,
        errors: ['Erro inesperado: $e'],
      );
    }
  }

  /// Confirma múltiplos agendamentos em lote
  Future<BatchOperationResult> confirmAppointments(List<Appointment> appointments) async {
    state = const AsyncValue.loading();
    
    try {
      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      // Processa todas as confirmações em paralelo para maior eficiência
      await Future.wait(appointments.map((appointment) async {
        try {
          await _appointmentsService.updateAppointmentStatus(
            appointment.id, 
            AppointmentStatus.confirmed,
          );
          
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Erro ao confirmar agendamento de ${appointment.clientName}: $e');
        }
      }));

      // Recarregar a lista de agendamentos se houver sucesso
      if (successCount > 0) {
        _read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        _read(allAppointmentsProvider.notifier).invalidateSelf();
      }

      final result = BatchOperationResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
      
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return BatchOperationResult(
        successCount: 0,
        failureCount: appointments.length,
        errors: ['Erro inesperado: $e'],
      );
    }
  }
}

/// Provider para o controller de operações em lote
final batchOperationsControllerProvider = StateNotifierProvider.autoDispose<
    BatchOperationsController, AsyncValue<BatchOperationResult>>((ref) {
  final appointmentsService = ref.watch(appointmentsServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return BatchOperationsController(appointmentsService, notificationService, ref.read);
});