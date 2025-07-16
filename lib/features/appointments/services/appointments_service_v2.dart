import '../../../core/services/api_service.dart';
import '../../../core/models/appointment_model.dart';

class AppointmentsServiceV2 {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> appointmentData,
  ) async {
    return await _apiService.put('/appointments/$appointmentId', appointmentData);
  }

  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) async {
    return await _apiService.delete('/appointments/$appointmentId');
  }

class AppointmentsServiceV2 {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> createAppointment({
    required String professionalId,
    required String serviceId,
    required DateTime appointmentDateTime,
    required String clientName,
    required String clientPhone,
    required String service,
    required double price,
    String? notes,
  }) async {
    final data = {
      'professionalId': professionalId,
      'serviceId': serviceId,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'clientName': clientName,
      'clientPhone': clientPhone,
      'service': service,
      'price': price,
      'notes': notes ?? '',
    };

    return await _apiService.post('/appointments', data);
  }

  Future<Map<String, dynamic>> getAppointments({String? status}) async {
    String endpoint = '/appointments';
    if (status != null) {
      endpoint += '?status=$status';
    }
    return await _apiService.get(endpoint);
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    final data = {'status': newStatus};
    return await _apiService.put('/appointments/$appointmentId', data);
  }

  Future<List<Appointment>> getAppointmentsList({String? status}) async {
    try {
      final response = await getAppointments(status: status);
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Appointment.fromDynamoJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    final data = {'status': newStatus};
    return await _apiService.put('/appointments/$appointmentId', data);
  }

  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) async {
    return await _apiService.delete('/appointments/$appointmentId');
  }

  Future<Appointment> createAppointmentModel({
    required String professionalId,
    required String serviceId,
    required DateTime appointmentDateTime,
    required String clientName,
    required String clientPhone,
    required String service,
    required double price,
    String? notes,
  }) async {
    try {
      final response = await createAppointment(
        professionalId: professionalId,
        serviceId: serviceId,
        appointmentDateTime: appointmentDateTime,
        clientName: clientName,
        clientPhone: clientPhone,
        service: service,
        price: price,
        notes: notes,
      );

      if (response['success'] == true) {
        return Appointment.fromDynamoJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar agendamento');
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }
}