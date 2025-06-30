import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static Future<http.Response> get(String url) async {
    return await http.get(Uri.parse(url));
  }

  static Future<http.Response> post(String url, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  static Future<http.Response> put(String url, Map<String, dynamic> data) async {
    return await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  static Future<http.Response> delete(String url) async {
    return await http.delete(Uri.parse(url));
  }
}