import 'dart:convert';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/aws_config.dart';

class ClienteService {
  static Future<List<Map<String, dynamic>>> getClientes() async {
    if (!AuthService.isAuthenticated) return [];
    
    try {
      final response = await ApiClient.get(AWSConfig.clientesEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Erro ao buscar clientes: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> criarCliente(Map<String, dynamic> cliente) async {
    if (!AuthService.isAuthenticated) return null;
    
    try {
      cliente['userId'] = AuthService.userId;
      
      final response = await ApiClient.post(
        AWSConfig.clientesEndpoint,
        cliente,
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erro ao criar cliente: $e');
    }
    return null;
  }

  static Future<bool> deletarCliente(String id) async {
    if (!AuthService.isAuthenticated) return false;
    
    try {
      final response = await ApiClient.delete('${AWSConfig.clientesEndpoint}/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar cliente: $e');
      return false;
    }
  }
}