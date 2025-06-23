import 'package:flutter/foundation.dart';
import '../../../shared/models/appointment_model.dart';
import '../../../core/services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments({String? date, String? status}) async {
    _setLoading(true);
    _clearError();

    try {
      String endpoint = '/appointments';
      List<String> queryParams = [];
      
      if (date != null) queryParams.add('date=$date');
      if (status != null) queryParams.add('status=$status');
      
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await ApiService.get(endpoint);
      final appointmentsData = response['data'] as List;
      
      _appointments = appointmentsData
          .map((data) => AppointmentModel.fromJson(data))
          .toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> createAppointment(Map<String, dynamic> appointmentData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/appointments', appointmentData);
      final newAppointment = AppointmentModel.fromJson(response['data']);
      
      _appointments.add(newAppointment);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/appointments/$appointmentId', updates);
      final updatedAppointment = AppointmentModel.fromJson(response['data']);
      
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    _setLoading(true);
    _clearError();

    try {
      await ApiService.delete('/appointments/$appointmentId');
      
      _appointments.removeWhere((apt) => apt.id == appointmentId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  List<AppointmentModel> getAppointmentsByDate(DateTime date) {
    final dateString = date.toIso8601String().split('T')[0];
    return _appointments
        .where((apt) => apt.appointmentDate.toIso8601String().split('T')[0] == dateString)
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}