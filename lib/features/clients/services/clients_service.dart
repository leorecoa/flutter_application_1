import '../../../core/services/api_service.dart';
import '../../../core/models/client_model.dart';

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
    return await _apiService.delete('/clients/$clientId');
  }

  Future<List<Client>> getClientsList() async {
    try {
      final response = await getClients();
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Client.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar clientes: $e');
    }
  }

  Future<Client> createClientModel({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    try {
      final response = await createClient({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      });

      if (response['success'] == true) {
        return Client.fromJson(response['data']);
      }
      
      throw Exception(response['message'] ?? 'Erro ao criar cliente');
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }
}