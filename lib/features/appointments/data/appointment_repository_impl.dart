import '../../../core/services/api_service.dart';
import '../../../core/models/appointment_model.dart';
import '../domain/appointment_repository.dart';

/// Implementação do repositório de agendamentos usando o serviço de API
class AppointmentRepositoryImpl implements AppointmentRepository {
  final ApiService _apiService;
  
  AppointmentRepositoryImpl(this._apiService);
  
  @override
  Future<List<Appointment>> getAllAppointments() async {
    try {
      final response = await _apiService.get('/appointments');
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Appointment.fromDynamoJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }
  
  @override
  Future<List<Appointment>> getPaginatedAppointments({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  }) async {
    try {
      String endpoint = '/appointments/paginated?page=$page&pageSize=$pageSize';
      
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, value) {
          if (value != null) {
            endpoint += '&$key=$value';
          }
        });
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Appointment.fromDynamoJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos paginados: $e');
    }
  }
  
  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final data = appointment.toDynamoJson();
      final response = await _apiService.post('/appointments', data);
      
      if (response['success'] == true) {
        return Appointment.fromDynamoJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar agendamento');
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }
  
  @override
  Future<Appointment> updateAppointment(Appointment appointment) async {
    try {
      final data = appointment.toDynamoJson();
      final response = await _apiService.put('/appointments/${appointment.id}', data);
      
      if (response['success'] == true) {
        return Appointment.fromDynamoJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao atualizar agendamento');
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento: $e');
    }
  }
  
  @override
  Future<void> deleteAppointment(String id) async {
    try {
      final response = await _apiService.delete('/appointments/$id');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Erro ao excluir agendamento');
      }
    } catch (e) {
      throw Exception('Erro ao excluir agendamento: $e');
    }
  }
  
  @override
  Future<Appointment> updateAppointmentStatus(String id, AppointmentStatus status) async {
    try {
      final data = {'status': status.toString().split('.').last};
      final response = await _apiService.put('/appointments/$id/status', data);
      
      if (response['success'] == true) {
        return Appointment.fromDynamoJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao atualizar status do agendamento');
    } catch (e) {
      throw Exception('Erro ao atualizar status do agendamento: $e');
    }
  }
  
  @override
  Future<Appointment> updateClientConfirmation(String id, bool isConfirmed) async {
    try {
      final data = {'confirmedByClient': isConfirmed};
      final response = await _apiService.put('/appointments/$id/client-confirmation', data);
      
      if (response['success'] == true) {
        return Appointment.fromDynamoJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao atualizar confirmação do cliente');
    } catch (e) {
      throw Exception('Erro ao atualizar confirmação do cliente: $e');
    }
  }
  
  @override
  Future<List<Appointment>> createBatchAppointments(List<Appointment> appointments) async {
    try {
      final data = {
        'appointments': appointments.map((a) => a.toDynamoJson()).toList(),
      };
      
      final response = await _apiService.post('/appointments/batch', data);
      
      if (response['success'] == true) {
        final List<dynamic> responseData = response['data'] ?? [];
        return responseData.map((json) => Appointment.fromDynamoJson(json)).toList();
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar agendamentos em lote');
    } catch (e) {
      throw Exception('Erro ao criar agendamentos em lote: $e');
    }
  }
  
  @override
  Future<List<Appointment>> updateBatchStatus(
    List<String> ids, 
    AppointmentStatus status,
  ) async {
    try {
      final data = {
        'ids': ids,
        'status': status.toString().split('.').last,
      };
      
      final response = await _apiService.put('/appointments/batch/status', data);
      
      if (response['success'] == true) {
        final List<dynamic> responseData = response['data'] ?? [];
        return responseData.map((json) => Appointment.fromDynamoJson(json)).toList();
      }
      
      throw Exception(response['message'] ?? 'Erro ao atualizar status em lote');
    } catch (e) {
      throw Exception('Erro ao atualizar status em lote: $e');
    }
  }
}