import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para excluir um agendamento
class DeleteAppointmentUseCase {
  final AppointmentRepository _repository;

  /// Construtor
  DeleteAppointmentUseCase(this._repository);

  /// Executa o caso de uso
  Future<void> execute(String appointmentId) async {
    try {
      // Validação básica
      if (appointmentId.isEmpty) {
        throw ValidationException('ID do agendamento é obrigatório');
      }

      // Exclui o agendamento
      await _repository.deleteAppointment(appointmentId);

      Logger.info(
        'Agendamento excluído com sucesso',
        context: {'appointmentId': appointmentId},
      );
    } on ValidationException catch (e) {
      Logger.error('Erro de validação ao excluir agendamento', error: e);
      rethrow;
    } catch (e) {
      Logger.error('Erro ao excluir agendamento', error: e);
      throw UseCaseException('Erro ao excluir agendamento: $e');
    }
  }
}
