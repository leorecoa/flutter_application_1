import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/notification_service.dart';
import 'appointment_providers.dart';

/// Controller para gerenciar a criação de agendamentos recorrentes
class RecurringAppointmentController
    extends StateNotifier<AsyncValue<RecurringAppointmentResult>> {
  final Reader _read;

  RecurringAppointmentController(this._read)
    : super(const AsyncValue.data(RecurringAppointmentResult(0, [])));

  /// Cria múltiplos agendamentos recorrentes
  Future<RecurringAppointmentResult> createRecurringAppointments(
    List<Appointment> appointments,
  ) async {
    state = const AsyncValue.loading();
    try {
      final appointmentsService = _read(appointmentsServiceProvider);
      final notificationService = _read(notificationServiceProvider);
      int successCount = 0;
      final List<String> errors = [];

      // Processa todas as criações em paralelo para maior eficiência
      await Future.wait(
        appointments.map((appointment) async {
          try {
            final response = await appointmentsService.createAppointment(
              professionalId: appointment.professionalId,
              serviceId: appointment.serviceId,
              appointmentDateTime: appointment.dateTime,
              clientName: appointment.clientName,
              clientPhone: appointment.clientPhone,
              service: appointment.service,
              price: appointment.price,
              notes: appointment.notes,
              clientId: appointment.clientId,
              duration: appointment.duration,
            );

            if (response['success'] == true) {
              await notificationService.scheduleAppointmentReminders(
                appointment,
              );
              successCount++;
            } else {
              errors.add(
                response['message'] ??
                    'Erro ao criar ${appointment.clientName}',
              );
            }
          } catch (e) {
            errors.add(
              'Erro de conexão ao criar agendamento para ${appointment.clientName}',
            );
          }
        }),
      );

      // Recarrega a lista de agendamentos se houver sucesso
      if (successCount > 0) {
        _read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
      }

      final result = RecurringAppointmentResult(successCount, errors);
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return RecurringAppointmentResult(0, ['Erro inesperado: $e']);
    }
  }
}

/// Resultado da criação de agendamentos recorrentes
class RecurringAppointmentResult {
  final int successCount;
  final List<String> errors;

  const RecurringAppointmentResult(this.successCount, this.errors);
}

/// Provider para o controller de agendamentos recorrentes
final recurringAppointmentControllerProvider =
    StateNotifierProvider.autoDispose<
      RecurringAppointmentController,
      AsyncValue<RecurringAppointmentResult>
    >((ref) {
      return RecurringAppointmentController(ref.read);
    });
