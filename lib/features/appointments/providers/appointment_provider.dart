import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments({String? date, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (date != null) params['date'] = date;
      if (status != null) params['status'] = status;

      final response = await _apiService.get('/appointments', params);
      
      if (response['success'] == true) {
        final List<dynamic> appointmentsData = response['data'] ?? [];
        _appointments = appointmentsData.map((json) => AppointmentModel.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Erro ao carregar agendamentos';
        _appointments = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _appointments = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAppointment(Map<String, dynamic> appointmentData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/appointments', appointmentData);
      
      if (response['success'] == true) {
        await loadAppointments(); // Reload appointments
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao criar agendamento';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/appointments/$appointmentId', appointmentData);
      
      if (response['success'] == true) {
        await loadAppointments(); // Reload appointments
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao atualizar agendamento';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.delete('/appointments/$appointmentId');
      
      if (response['success'] == true) {
        await loadAppointments(); // Reload appointments
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao excluir agendamento';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}