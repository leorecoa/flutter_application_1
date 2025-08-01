import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para criar agendamentos recorrentes
class CreateRecurringAppointmentsUseCase {
  final AppointmentRepository _repository;
  
  CreateRecurringAppointmentsUseCase(this._repository);
  
  /// Executa o caso de uso
  Future<List<dynamic>> execute(List<dynamic> appointments) async {
    try {
      // Validação básica
      if (appointments.isEmpty) {
        throw Exception('Lista de agendamentos não pode estar vazia');
      }
      
      return await _repository.createRecurringAppointments(appointments);
    } catch (e) {
      throw Exception('Erro ao criar agendamentos recorrentes: ${e.toString()}');
    }
  }
}