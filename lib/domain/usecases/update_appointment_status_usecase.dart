import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para atualizar o status de um agendamento
class UpdateAppointmentStatusUseCase {
  final AppointmentRepository _repository;
  
  UpdateAppointmentStatusUseCase(this._repository);
  
  /// Executa o caso de uso
  Future<void> execute(String appointmentId, String newStatus) async {
    try {
      // Validação básica
      if (appointmentId.isEmpty) {
        throw Exception('ID do agendamento é obrigatório');
      }
      
      if (newStatus.isEmpty) {
        throw Exception('Status é obrigatório');
      }
      
      // Validação de status permitidos
      final validStatuses = ['scheduled', 'confirmed', 'completed', 'cancelled'];
      if (!validStatuses.contains(newStatus.toLowerCase())) {
        throw Exception(
            'Status inválido. Use: ${validStatuses.join(", ")}');
      }
      
      await _repository.updateAppointmentStatus(appointmentId, newStatus);
    } catch (e) {
      throw Exception('Erro ao atualizar status: ${e.toString()}');
    }
  }
}