import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para atualizar um agendamento
class UpdateAppointmentUseCase {
  final AppointmentRepository _repository;

  /// Construtor
  UpdateAppointmentUseCase(this._repository);

  /// Executa o caso de uso
  Future<Appointment> execute(Appointment appointment) async {
    try {
      // Validação básica
      if (appointment.id.isEmpty) {
        throw ValidationException('ID do agendamento é obrigatório');
      }

      if (appointment.clientName.isEmpty) {
        throw ValidationException('Nome do cliente é obrigatório');
      }

      if (appointment.serviceName.isEmpty) {
        throw ValidationException('Nome do serviço é obrigatório');
      }

      // Verifica se a data/hora é válida
      final now = DateTime.now();
      if (appointment.date.isBefore(now) && appointment.date.day != now.day) {
        throw ValidationException('Não é possível agendar para datas passadas');
      }

      // Atualiza o agendamento
      final updatedAppointment = await _repository.updateAppointment(
        appointment,
      );

      Logger.info(
        'Agendamento atualizado com sucesso',
        context: {
          'appointmentId': updatedAppointment.id,
          'clientName': updatedAppointment.clientName,
        },
      );

      return updatedAppointment;
    } on ValidationException catch (e) {
      Logger.error('Erro de validação ao atualizar agendamento', error: e);
      rethrow;
    } catch (e) {
      Logger.error('Erro ao atualizar agendamento', error: e);
      throw UseCaseException('Erro ao atualizar agendamento: $e');
    }
  }
}
