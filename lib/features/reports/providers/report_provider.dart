import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _servicesReport;
  Map<String, dynamic>? _clientsReport;
  Map<String, dynamic>? _financialReport;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get servicesReport => _servicesReport;
  Map<String, dynamic>? get clientsReport => _clientsReport;
  Map<String, dynamic>? get financialReport => _financialReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServicesReport({String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (startDate != null) params['startDate'] = startDate;
      if (endDate != null) params['endDate'] = endDate;

      final response = await _apiService.get('/relatorios/servicos', params);
      
      if (response['success'] == true) {
        _servicesReport = response['data'];
      } else {
        _error = response['message'] ?? 'Erro ao carregar relatório de serviços';
        _servicesReport = null;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _servicesReport = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFinancialReport({
    String? startDate, 
    String? endDate, 
    String groupBy = 'day'
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'groupBy': groupBy};
      if (startDate != null) params['startDate'] = startDate;
      if (endDate != null) params['endDate'] = endDate;

      final response = await _apiService.get('/relatorios/financeiro', params);
      
      if (response['success'] == true) {
        _financialReport = response['data'];
      } else {
        _error = response['message'] ?? 'Erro ao carregar relatório financeiro';
        _financialReport = null;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _financialReport = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> exportReport({
    required String reportType,
    String format = 'csv',
    Map<String, dynamic>? params
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/relatorios/export', {
        'reportType': reportType,
        'format': format,
        'params': params ?? {},
      });
      
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return response['data']['downloadUrl'];
      } else {
        _error = response['message'] ?? 'Erro ao exportar relatório';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}