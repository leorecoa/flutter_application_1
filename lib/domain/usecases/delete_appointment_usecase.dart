import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para excluir agendamentos
class DeleteAppointmentUseCase {
  final AppointmentRepository _repository;
  
  DeleteAppointmentUseCase(this._repository);
  
  /// Executa o caso de uso
  Future<void> execute(String appointmentId) async {
    try {
      // Validação básica
      if (appointmentId.isEmpty) {
        throw Exception('ID do agendamento é obrigatório');
      }
      
      await _repository.deleteAppointment(appointmentId);
    } catch (e) {
      throw Exception('Erro ao excluir agendamento: ${e.toString()}');
    }
  }
}