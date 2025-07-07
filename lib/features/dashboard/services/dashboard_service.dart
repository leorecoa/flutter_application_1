import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiService _apiService = ApiService();
  
  // Cache for frequently accessed data
  Map<String, dynamic>? _cachedStats;
  DateTime? _lastStatsUpdate;

  Future<Map<String, dynamic>> getDashboardStats({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh && 
        _cachedStats != null && 
        _lastStatsUpdate != null &&
        DateTime.now().difference(_lastStatsUpdate!) < AppConstants.cacheTimeout) {
      return _cachedStats!;
    }

    final response = await _apiService.get('/dashboard/stats');
    
    if (response['success'] == true) {
      _cachedStats = response['data'];
      _lastStatsUpdate = DateTime.now();
      return _cachedStats!;
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar estatísticas do dashboard');
    }
  }

  Future<Map<String, dynamic>> getNextAppointments({
    int page = 0, 
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final uri = Uri.parse('/dashboard/appointments').replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );

    final response = await _apiService.get(uri.toString());
    
    if (response['success'] == true) {
      return {
        'appointments': response['data']['appointments'] ?? [],
        'total': response['data']['total'] ?? 0,
        'hasMore': response['data']['hasMore'] ?? false,
      };
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar agendamentos');
    }
  }

  Future<Map<String, dynamic>> getRecentActivity({
    int limit = 10,
  }) async {
    final response = await _apiService.get('/dashboard/activity?limit=$limit');
    
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar atividades recentes');
    }
  }

  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final response = await _apiService.get('/dashboard/metrics', useCache: true);
    
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar métricas de performance');
    }
  }

  Future<Map<String, dynamic>> getFinancialSummary() async {
    final response = await _apiService.get('/dashboard/financial');
    
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar resumo financeiro');
    }
  }

  Future<Map<String, dynamic>> getClientStats() async {
    final response = await _apiService.get('/dashboard/clients');
    
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar estatísticas de clientes');
    }
  }

  void clearCache() {
    _cachedStats = null;
    _lastStatsUpdate = null;
    _apiService.clearCache();
  }
}