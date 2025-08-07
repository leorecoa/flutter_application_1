import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para atualizar o status de um agendamento
class UpdateAppointmentStatusUseCase {
  final AppointmentRepository _repository;

  /// Construtor
  UpdateAppointmentStatusUseCase(this._repository);

  /// Executa o caso de uso
  Future<void> execute(String appointmentId, String status) async {
    try {
      // Validação básica
      if (appointmentId.isEmpty) {
        throw ValidationException('ID do agendamento é obrigatório');
      }

      if (status.isEmpty) {
        throw ValidationException('Status é obrigatório');
      }

      // Converte a string para o enum
      final AppointmentStatus appointmentStatus;
      try {
        appointmentStatus = AppointmentStatus.fromString(status);
      } catch (e) {
        throw ValidationException('Status inválido: $status');
      }

      // Atualiza o status do agendamento
      await _repository.updateAppointmentStatus(
        appointmentId,
        appointmentStatus,
      );

      Logger.info(
        'Status do agendamento atualizado com sucesso',
        context: {'appointmentId': appointmentId, 'status': status},
      );
    } on ValidationException catch (e) {
      Logger.error('Erro de validação ao atualizar status', error: e);
      rethrow;
    } catch (e) {
      Logger.error('Erro ao atualizar status', error: e);
      throw UseCaseException('Erro ao atualizar status: $e');
    }
  }
}
