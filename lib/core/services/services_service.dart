import 'api_service.dart';

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
    return await _apiService.post('/services/$serviceId/delete', {});
  }
}