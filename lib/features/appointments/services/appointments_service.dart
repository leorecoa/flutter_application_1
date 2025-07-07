import '../../../core/services/api_service.dart';
import '../../../core/models/appointment_model.dart';

class AppointmentsService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getAppointments() async {
    return await _apiService.get('/appointments');
  }

  Future<Appointment> createAppointment({
    required String clientName,
    required String clientPhone,
    required String service,
    required DateTime dateTime,
    required double price,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('/appointments', {
        'clientName': clientName,
        'clientPhone': clientPhone,
        'service': service,
        'dateTime': dateTime.toIso8601String(),
        'price': price,
        'notes': notes ?? '',
      });
      
      if (response['success'] == true) {
        return Appointment.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar agendamento');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Appointment> updateAppointment(String id, {
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put('/appointments/$id', {
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      });
      
      if (response['success'] == true) {
        return Appointment.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao atualizar agendamento');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}