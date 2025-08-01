import '../../../core/services/api_service.dart';

class ClientsService {
  final _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await _apiService.get('/clients');
    final data = response['data'] as List<dynamic>?;
    return data?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Alias para getClients para compatibilidade
  Future<List<Map<String, dynamic>>> getClientsList() async {
    return getClients();
  }

  Future<Map<String, dynamic>> createClient(
    Map<String, dynamic> clientData,
  ) async {
    final response = await _apiService.post('/clients', body: clientData);
    return response;
  }

  /// Cria um modelo de cliente
  Map<String, dynamic> createClientModel({
    required String name,
    required String phone,
    String? email,
    String? notes,
  }) {
    return {'name': name, 'phone': phone, 'email': email, 'notes': notes};
  }

  /// Atualiza um cliente
  Future<Map<String, dynamic>> updateClient(
    String clientId,
    Map<String, dynamic> clientData,
  ) async {
    final response = await _apiService.put(
      '/clients/$clientId',
      body: clientData,
    );
    return response;
  }

  /// Deleta um cliente
  Future<Map<String, dynamic>> deleteClient(String clientId) async {
    final response = await _apiService.delete('/clients/$clientId');
    return response;
  }
}
