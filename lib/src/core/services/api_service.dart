import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, required this.baseUrl});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception(
        'Falha na chamada à API: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
