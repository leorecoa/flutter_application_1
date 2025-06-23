import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      // Get today's appointments
      final today = DateTime.now().toIso8601String().split('T')[0];
      final appointmentsResponse = await ApiService.get('/appointments?date=$today&limit=10');
      
      // Get total appointments count
      final allAppointmentsResponse = await ApiService.get('/appointments');
      
      // Calculate metrics
      final todayAppointments = appointmentsResponse['data'] as List;
      final allAppointments = allAppointmentsResponse['data'] as List;
      
      final totalRevenue = allAppointments
          .where((apt) => apt['paymentStatus'] == 'paid')
          .fold(0.0, (sum, apt) => sum + (apt['servicePrice'] ?? 0.0));
      
      final totalClients = allAppointments
          .map((apt) => apt['clientPhone'])
          .toSet()
          .length;

      _dashboardData = {
        'todayAppointments': todayAppointments,
        'totalAppointments': allAppointments.length,
        'totalRevenue': totalRevenue,
        'totalClients': totalClients,
        'pendingAppointments': allAppointments
            .where((apt) => apt['status'] == 'scheduled')
            .length,
      };

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
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