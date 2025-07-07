import 'api_service.dart';

class AppointmentsService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getAppointments({
    String? date,
    String? status,
    int? limit,
  }) async {
    final params = <String, String>{};
    if (date != null) params['date'] = date;
    if (status != null) params['status'] = status;
    if (limit != null) params['limit'] = limit.toString();

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/appointments${query.isNotEmpty ? '?$query' : ''}';
    
    return await _apiService.get(path);
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    return await _apiService.post('/appointments', appointmentData);
  }

  Future<Map<String, dynamic>> updateAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    return await _apiService.put('/appointments/$appointmentId', appointmentData);
  }

  Future<Map<String, dynamic>> cancelAppointment(String appointmentId) async {
    return await _apiService.put('/appointments/$appointmentId/cancel', {});
  }

  Future<Map<String, dynamic>> confirmAppointment(String appointmentId) async {
    return await _apiService.put('/appointments/$appointmentId/confirm', {});
  }

  Future<Map<String, dynamic>> getAppointmentById(String appointmentId) async {
    return await _apiService.get('/appointments/$appointmentId');
  }
}