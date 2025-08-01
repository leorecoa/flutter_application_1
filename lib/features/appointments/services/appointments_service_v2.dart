import '../../../core/models/appointment_model.dart';
import '../domain/appointment_repository.dart';

/// Serviço de agendamentos V2 - Versão refatorada usando Repository Pattern
class AppointmentsServiceV2 {
  final AppointmentRepository _repository;

  AppointmentsServiceV2(this._repository);

  Future<Appointment> createAppointment({
    required String professionalId,
    required String serviceId,
    required DateTime appointmentDateTime,
    required String clientName,
    required String clientPhone,
    required String service,
    required double price,
    String? notes,
  }) async {
    final appointment = Appointment(
      id: '', // ID será gerado pelo backend
      professionalId: professionalId,
      serviceId: serviceId,
      dateTime: appointmentDateTime,
      clientName: clientName,
      clientPhone: clientPhone,
      service: service,
      price: price,
      notes: notes ?? '',
      status: AppointmentStatus.scheduled,
      confirmedByClient: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createAppointment(appointment);
  }

  Future<List<Appointment>> getAppointments({String? status}) async {
    Map<String, dynamic>? filters;
    if (status != null) {
      filters = {'status': status};
    }
    return await _repository.getAllAppointments();
  }

  Future<Appointment> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus newStatus,
  ) async {
    return await _repository.updateAppointmentStatus(appointmentId, newStatus);
  }

  Future<List<Appointment>> getAppointmentsList({String? status}) async {
    try {
      Map<String, dynamic>? filters;
      if (status != null) {
        filters = {'status': status};
      }
      return await _repository.getAllAppointments();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  Future<Appointment> updateAppointment(Appointment appointment) async {
    return await _repository.updateAppointment(appointment);
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _repository.deleteAppointment(appointmentId);
  }

  Future<List<Appointment>> createBatchAppointments(
    List<Appointment> appointments,
  ) async {
    return await _repository.createBatchAppointments(appointments);
  }

  Future<List<Appointment>> updateBatchStatus(
    List<String> ids,
    AppointmentStatus status,
  ) async {
    return await _repository.updateBatchStatus(ids, status);
  }

  Future<Appointment> updateClientConfirmation(
    String id,
    bool isConfirmed,
  ) async {
    return await _repository.updateClientConfirmation(id, isConfirmed);
  }
}
