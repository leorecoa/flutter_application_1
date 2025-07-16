import '../../../core/services/api_service.dart';
import '../../../core/models/service_model.dart';

class ServicesService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getServices() async {
    return await _apiService.get('/services');
  }

  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    return await _apiService.post('/services', serviceData);
  }

  Future<Map<String, dynamic>> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    return await _apiService.put('/services/$serviceId', serviceData);
  }

  Future<Map<String, dynamic>> deleteService(String serviceId) async {
    return await _apiService.delete('/services/$serviceId');
  }

  Future<List<Service>> getServicesList() async {
    try {
      final response = await getServices();
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Service.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar serviços: $e');
    }
  }

  Future<Service> createServiceModel({
    required String name,
    required int duration,
    required double price,
    String? description,
  }) async {
    try {
      final response = await createService({
        'name': name,
        'duration': duration,
        'price': price,
        'description': description,
      });

      if (response['success'] == true) {
        return Service.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar serviço');
    } catch (e) {
      throw Exception('Erro ao criar serviço: $e');
    }
  }
}