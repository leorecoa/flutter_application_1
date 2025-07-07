import 'api_service.dart';

class ClientsService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> getClients() async {
    return await _apiService.get('/clients');
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> clientData) async {
    return await _apiService.post('/clients', clientData);
  }

  Future<Map<String, dynamic>> updateClient(String clientId, Map<String, dynamic> clientData) async {
    return await _apiService.put('/clients/$clientId', clientData);
  }

  Future<Map<String, dynamic>> deleteClient(String clientId) async {
    return await _apiService.post('/clients/$clientId/delete', {});
  }

  Future<Map<String, dynamic>> getClientById(String clientId) async {
    return await _apiService.get('/clients/$clientId');
  }
}