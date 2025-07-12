import '../../../core/services/api_service.dart';

class AppointmentsService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getAppointments() async {
    return await _apiService.get('/appointments');
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> appointmentData) async {
    return await _apiService.post('/appointments', appointmentData);
  }

  Future<Map<String, dynamic>> updateAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    return await _apiService.put('/appointments/$appointmentId', appointmentData);
  }
}