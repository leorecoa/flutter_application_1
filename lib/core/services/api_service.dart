import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _authToken;
  User? _currentUser;
  
  // Cache for API responses
  final Map<String, CacheEntry> _cache = {};
  
  String? get authToken => _authToken;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.authTokenKey);
    final userData = prefs.getString(AppConstants.userDataKey);
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
    }
  }
  
  Future<void> setAuthToken(String token, User user) async {
    _authToken = token;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }
  
  Future<void> clearAuthToken() async {
    _authToken = null;
    _currentUser = null;
    _cache.clear(); // Clear cache on logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }
  
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final response = await _makeRealApiCall('POST', path, data);
    
    // Se for login bem-sucedido, salvar dados
    if (path == '/auth/login' && response['success'] == true) {
      await setAuthToken(response['token'], User.fromJson(response['user']));
    }
    
    return response;
  }
  
  Future<Map<String, dynamic>> get(String path, {bool useCache = true}) async {
    // Check cache first for GET requests
    if (useCache && _cache.containsKey(path)) {
      final cacheEntry = _cache[path]!;
      if (DateTime.now().difference(cacheEntry.timestamp) < AppConstants.cacheTimeout) {
        return cacheEntry.data;
      } else {
        _cache.remove(path); // Remove expired cache
      }
    }
    
    final response = await _makeRealApiCall('GET', path, null);
    
    // Cache successful GET responses
    if (useCache && response['success'] != false) {
      _cache[path] = CacheEntry(response, DateTime.now());
    }
    
    return response;
  }
  
  Future<Map<String, dynamic>> generatePix({
    required double valor,
    required String descricao,
  }) async {
    return await _makeRealApiCall('POST', '/payments/pix', {
      'amount': valor,
      'description': descricao,
    });
  }
  
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> data) async {
    final response = await _makeRealApiCall('PUT', path, data);
    // Invalidate cache for PUT requests
    _cache.removeWhere((key, value) => key.startsWith(path.split('/')[1]));
    return response;
  }
  
  Future<Map<String, dynamic>> _makeRealApiCall(String method, String path, Map<String, dynamic>? data) async {
    int retries = 0;
    
    while (retries < AppConstants.maxRetries) {
      try {
        final url = Uri.parse('${AppConstants.apiBaseUrl}$path');
        final headers = {
          'Content-Type': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br', // Enable compression
          'Connection': 'keep-alive', // Keep connections alive
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        };
        
        http.Response response;
        
        switch (method) {
          case 'GET':
            response = await http.get(url, headers: headers).timeout(AppConstants.requestTimeout);
            break;
          case 'POST':
            response = await http.post(
              url,
              headers: headers,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(AppConstants.requestTimeout);
            break;
          case 'PUT':
            response = await http.put(
              url,
              headers: headers,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(AppConstants.requestTimeout);
            break;
          default:
            throw Exception('Método HTTP não suportado: $method');
        }
        
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseData;
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Erro na requisição',
          };
        }
        
      } catch (e) {
        retries++;
        if (retries >= AppConstants.maxRetries) {
          return {
            'success': false,
            'message': 'Erro de conexão após $retries tentativas: $e',
          };
        }
        
        // Exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * retries));
      }
    }
    
    return {
      'success': false,
      'message': 'Máximo de tentativas excedido',
    };
  }
  
  void clearCache() {
    _cache.clear();
  }
}

class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  CacheEntry(this.data, this.timestamp);
}