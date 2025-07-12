import '../../../core/services/api_service.dart';

class ReportsService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _apiService.get('/reports/financial?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}');
  }

  Future<Map<String, dynamic>> getAppointmentsReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _apiService.get('/reports/appointments?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}');
  }

  Future<Map<String, dynamic>> getClientsReport() async {
    return await _apiService.get('/reports/clients');
  }

  Future<Map<String, dynamic>> getServicesReport() async {
    return await _apiService.get('/reports/services');
  }
}