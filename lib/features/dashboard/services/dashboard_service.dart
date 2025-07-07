import '../../../core/services/api_service.dart';

class DashboardService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/dashboard/stats');
      
      if (response['success'] == true) {
        return response['data'];
      }
      
      throw Exception(response['message'] ?? 'Erro ao buscar estatísticas');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}