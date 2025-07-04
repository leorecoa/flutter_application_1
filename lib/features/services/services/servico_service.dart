import 'dart:convert';

import '../../../core/config/aws_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

class ServicoService {
  static Future<List<Map<String, dynamic>>> getServicos() async {
    if (!AuthService.isAuthenticated) return [];

    try {
      final response = await ApiClient.get(AWSConfig.servicosEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao buscar serviços: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> criarServico(
      Map<String, dynamic> servico) async {
    if (!AuthService.isAuthenticated) return null;

    try {
      servico['userId'] = AuthService.userId;

      final response = await ApiClient.post(
        AWSConfig.servicosEndpoint,
        servico,
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao criar serviço: $e');
    }
    return null;
  }

  static Future<bool> deletarServico(String id) async {
    if (!AuthService.isAuthenticated) return false;

    try {
      final response =
          await ApiClient.delete('${AWSConfig.servicosEndpoint}/$id');
      return response.statusCode == 204;
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao deletar serviço: $e');
      return false;
    }
  }
}
