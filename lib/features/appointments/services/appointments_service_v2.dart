import '../../../core/services/api_service.dart';
import '../../../core/models/appointment_model.dart';

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
    String? clientId,
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
      'clientId': clientId,
    };

    return await _apiService.post('/appointments', data);
  }

  Future<Map<String, dynamic>> getAppointments({String? status, DateTime? date}) async {
    String endpoint = '/appointments';
    List<String> params = [];
    
    if (status != null) {
      params.add('status=$status');
    }
    
    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      params.add('date=$dateStr');
    }
    
    if (params.isNotEmpty) {
      endpoint += '?' + params.join('&');
    }
    
    return await _apiService.get(endpoint);
  }
  
  Future<bool> checkTimeConflict(DateTime appointmentDateTime, int durationMinutes) async {
    try {
      // Obter todos os agendamentos do dia
      final date = DateTime(appointmentDateTime.year, appointmentDateTime.month, appointmentDateTime.day);
      final response = await getAppointments(date: date);
      
      if (response['success'] != true) {
        return false;
      }
      
      final List<dynamic> data = response['data'] ?? [];
      final appointments = data.map((json) => Appointment.fromDynamoJson(json)).toList();
      
      // Filtrar apenas agendamentos confirmados ou agendados (não cancelados)
      final activeAppointments = appointments.where((a) => 
        a.status == AppointmentStatus.scheduled || 
        a.status == AppointmentStatus.confirmed
      ).toList();
      
      // Calcular horário de início e fim do novo agendamento
      final startTime = appointmentDateTime;
      final endTime = appointmentDateTime.add(Duration(minutes: durationMinutes));
      
      // Verificar se há conflito com algum agendamento existente
      for (final appointment in activeAppointments) {
        final existingStartTime = appointment.dateTime;
        final existingEndTime = existingStartTime.add(const Duration(minutes: 60)); // Assumindo 1h por padrão
        
        // Verificar sobreposição de horários
        if ((startTime.isAfter(existingStartTime) && startTime.isBefore(existingEndTime)) ||
            (endTime.isAfter(existingStartTime) && endTime.isBefore(existingEndTime)) ||
            (startTime.isBefore(existingStartTime) && endTime.isAfter(existingEndTime)) ||
            (startTime.isAtSameMomentAs(existingStartTime) || endTime.isAtSameMomentAs(existingEndTime))) {
          return true; // Há conflito
        }
      }
      
      return false; // Não há conflito
    } catch (e) {
      print('Erro ao verificar conflito de horário: $e');
      return false; // Em caso de erro, permitir agendamento
    }
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
    String? clientId,
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
        clientId: clientId,
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