import '../../../domain/entities/appointment.dart';

/// Interface para o repositório de agendamentos
abstract class AppointmentRepository {
  /// Obtém todos os agendamentos
  Future<List<Appointment>> getAllAppointments();

  /// Obtém agendamentos paginados
  Future<List<Appointment>> getPaginatedAppointments({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  });

  /// Cria um novo agendamento
  Future<Appointment> createAppointment(Appointment appointment);

  /// Atualiza um agendamento existente
  Future<Appointment> updateAppointment(Appointment appointment);

  /// Exclui um agendamento
  Future<void> deleteAppointment(String id);

  /// Atualiza o status de um agendamento
  Future<Appointment> updateAppointmentStatus(
    String id,
    AppointmentStatus status,
  );

  /// Atualiza a confirmação do cliente
  Future<Appointment> updateClientConfirmation(String id, bool isConfirmed);

  /// Cria múltiplos agendamentos (para agendamentos recorrentes)
  Future<List<Appointment>> createBatchAppointments(
    List<Appointment> appointments,
  );

  /// Atualiza o status de múltiplos agendamentos
  Future<List<Appointment>> updateBatchStatus(
    List<String> ids,
    AppointmentStatus status,
  );
}
