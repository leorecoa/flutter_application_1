import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/aws_config.dart';

class AuthService {
  static String? _accessToken;
  static String? _refreshToken;
  static String? _userId;

  static String? get accessToken => _accessToken;
  static String? get userId => _userId;
  static bool get isAuthenticated => _accessToken != null;

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AWSConfig.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['accessToken'];
        _refreshToken = data['refreshToken'];
        _userId = _decodeJWT(data['idToken'])['sub'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('${AWSConfig.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    
    return json.decode(decoded);
  }

  static Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
  }

  static Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${AWSConfig.authEndpoint}/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['accessToken'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }
}