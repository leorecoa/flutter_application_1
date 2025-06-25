import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  Future<Map<String, dynamic>> get(String endpoint, [Map<String, dynamic>? params]) async {
    var url = '${AppConfig.apiGatewayUrl}$endpoint';
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      url += '?$queryString';
    }
    
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConfig.apiGatewayUrl}$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConfig.apiGatewayUrl}$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiGatewayUrl}$endpoint');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro na API',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão',
        'error': e.toString(),
      };
    }
  }
}