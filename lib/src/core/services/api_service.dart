import 'dart:convert';
import 'package:agendafacil/src/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client client;
  final String baseUrl = AppConfig.baseUrl;

  ApiService({required this.client})
      : assert(AppConfig.baseUrl.isNotEmpty, 'BASE_URL não definida no .env');

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // Mesma chave usada no session_service
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response =
        await client.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final response = await client.post(Uri.parse('$baseUrl/$endpoint'),
        headers: headers, body: json.encode(body));
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final response = await client.put(Uri.parse('$baseUrl/$endpoint'),
        headers: headers, body: json.encode(body));
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response =
        await client.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null; // Para respostas 204 No Content
      return json.decode(response.body);
    } else {
      // Aqui você pode adicionar um tratamento de erro mais robusto
      throw Exception(
          'Falha na chamada à API: ${response.statusCode} - ${response.body}');
    }
  }
}

}
