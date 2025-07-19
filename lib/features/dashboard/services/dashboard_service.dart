import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/dashboard_stats_model.dart';

/// Provider para o serviço de dashboard
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

/// Serviço responsável por buscar estatísticas do dashboard
class DashboardService {
  final ApiService _apiService = ApiService();

  /// Busca estatísticas do dashboard
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/dashboard/stats');
      
      if (response['success'] == true) {
        return DashboardStats.fromJson(response['data']);
      }
      
      return DashboardStats.empty();
    } catch (e) {
      print('Erro ao buscar estatísticas do dashboard: $e');
      return DashboardStats.empty();
    }
  }

  /// Busca estatísticas do dashboard para um período específico
  Future<DashboardStats> getDashboardStatsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get(
        '/dashboard/stats?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
      );
      
      if (response['success'] == true) {
        return DashboardStats.fromJson(response['data']);
      }
      
      return DashboardStats.empty();
    } catch (e) {
      print('Erro ao buscar estatísticas do dashboard por período: $e');
      return DashboardStats.empty();
    }
  }

  /// Busca estatísticas de crescimento
  Future<Map<String, dynamic>> getGrowthStats() async {
    try {
      final response = await _apiService.get('/dashboard/growth');
      
      if (response['success'] == true) {
        return response['data'];
      }
      
      return {};
    } catch (e) {
      print('Erro ao buscar estatísticas de crescimento: $e');
      return {};
    }
  }

  /// Busca estatísticas de clientes
  Future<Map<String, dynamic>> getClientStats() async {
    try {
      final response = await _apiService.get('/dashboard/clients');
      
      if (response['success'] == true) {
        return response['data'];
      }
      
      return {};
    } catch (e) {
      print('Erro ao buscar estatísticas de clientes: $e');
      return {};
    }
  }
}