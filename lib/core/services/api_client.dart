import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static Future<http.Response> get(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: AuthService.getAuthHeaders(),
    );
    
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();
      if (refreshed) {
        return await http.get(
          Uri.parse(url),
          headers: AuthService.getAuthHeaders(),
        );
      }
    }
    
    return response;
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: AuthService.getAuthHeaders(),
      body: json.encode(body),
    );
    
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();
      if (refreshed) {
        return await http.post(
          Uri.parse(url),
          headers: AuthService.getAuthHeaders(),
          body: json.encode(body),
        );
      }
    }
    
    return response;
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: AuthService.getAuthHeaders(),
      body: json.encode(body),
    );
    
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();
      if (refreshed) {
        return await http.put(
          Uri.parse(url),
          headers: AuthService.getAuthHeaders(),
          body: json.encode(body),
        );
      }
    }
    
    return response;
  }

  static Future<http.Response> delete(String url) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: AuthService.getAuthHeaders(),
    );
    
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();
      if (refreshed) {
        return await http.delete(
          Uri.parse(url),
          headers: AuthService.getAuthHeaders(),
        );
      }
    }
    
    return response;
  }
}