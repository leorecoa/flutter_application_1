import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  
  int _todayAppointments = 0;
  int _monthlyAppointments = 0;
  double _monthlyRevenue = 0.0;
  int _totalClients = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayAppointments => _todayAppointments;
  int get monthlyAppointments => _monthlyAppointments;
  double get monthlyRevenue => _monthlyRevenue;
  int get totalClients => _totalClients;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/users/dashboard');
      
      if (response['success'] == true) {
        final data = response['data'];
        _todayAppointments = data['todayAppointments'] ?? 0;
        _monthlyAppointments = data['monthlyAppointments'] ?? 0;
        _monthlyRevenue = (data['monthlyRevenue'] ?? 0.0).toDouble();
        _totalClients = data['totalClients'] ?? 0;
      } else {
        _error = response['message'] ?? 'Erro ao carregar dados do dashboard';
        _resetData();
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _resetData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _resetData() {
    _todayAppointments = 0;
    _monthlyAppointments = 0;
    _monthlyRevenue = 0.0;
    _totalClients = 0;
  }
}