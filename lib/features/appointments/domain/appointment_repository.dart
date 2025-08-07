import 'package:flutter_application_1/core/models/appointment_model.dart';

/// Interface para o repositório de agendamentos.
///
/// Define o contrato para operações de dados de agendamentos,
/// seguindo os princípios da Clean Architecture. Note que todas as
/// operações exigem um [tenantId] para garantir o isolamento de dados.
abstract class IAppointmentRepository {
  Future<List<Appointment>> getAppointments({required String tenantId});
  Future<void> addAppointment(
      {required String tenantId, required Appointment appointment});
  Future<void> updateAppointment(
      {required String tenantId, required Appointment appointment});
  Future<void> deleteAppointment(
      {required String tenantId, required String appointmentId});
}
