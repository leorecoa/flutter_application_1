import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/multi_region_config.dart';

/// Serviço para comunicação com a API
class ApiService {
  /// Token de autenticação
  String? _authToken;
  
  /// Região atual
  String? _currentRegion;
  
  /// Endpoint base da API
  String? _baseUrl;
  
  /// Singleton
  static final ApiService _instance = ApiService._internal();
  
  /// Construtor factory
  factory ApiService() => _instance;
  
  /// Construtor interno
  ApiService._internal();
  
  /// Inicializa o serviço
  Future<void> init() async {
    _currentRegion = await MultiRegionConfig.getPreferredRegion();
    _baseUrl = await MultiRegionConfig.getApiEndpoint(region: _currentRegion);
  }
  
  /// Define o token de autenticação
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Limpa o token de autenticação
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// Obtém o token de autenticação
  String? get authToken => _authToken;
  
  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => _authToken != null;
  
  /// Altera a região da API
  Future<void> changeRegion(String region) async {
    await MultiRegionConfig.setPreferredRegion(region);
    _currentRegion = region;
    _baseUrl = await MultiRegionConfig.getApiEndpoint(region: region);
  }
  
  /// Obtém a região atual
  String get currentRegion => _currentRegion ?? MultiRegionConfig.defaultRegion;
  
  /// Realiza uma requisição GET
  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    if (_baseUrl == null) await init();
    
    final url = Uri.parse('$_baseUrl$path');
    final requestHeaders = _buildHeaders(headers);
    
    try {
      final response = await http.get(url, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      // Tenta fazer fallback para outra região em caso de erro
      return _handleError(e, () => get(path, headers: headers));
    }
  }
  
  /// Realiza uma requisição POST
  Future<dynamic> post(String path, dynamic body, {Map<String, String>? headers}) async {
    if (_baseUrl == null) await init();
    
    final url = Uri.parse('$_baseUrl$path');
    final requestHeaders = _buildHeaders(headers);
    
    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      // Tenta fazer fallback para outra região em caso de erro
      return _handleError(e, () => post(path, body, headers: headers));
    }
  }
  
  /// Realiza uma requisição PUT
  Future<dynamic> put(String path, dynamic body, {Map<String, String>? headers}) async {
    if (_baseUrl == null) await init();
    
    final url = Uri.parse('$_baseUrl$path');
    final requestHeaders = _buildHeaders(headers);
    
    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      // Tenta fazer fallback para outra região em caso de erro
      return _handleError(e, () => put(path, body, headers: headers));
    }
  }
  
  /// Realiza uma requisição DELETE
  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    if (_baseUrl == null) await init();
    
    final url = Uri.parse('$_baseUrl$path');
    final requestHeaders = _buildHeaders(headers);
    
    try {
      final response = await http.delete(url, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      // Tenta fazer fallback para outra região em caso de erro
      return _handleError(e, () => delete(path, headers: headers));
    }
  }
  
  /// Constrói os headers da requisição
  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }
  
  /// Trata a resposta da requisição
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response),
      );
    }
  }
  
  /// Trata erros de conexão com fallback para outra região
  Future<dynamic> _handleError(dynamic error, Future<dynamic> Function() retryCallback) async {
    // Se for um erro de API, não tenta fallback
    if (error is ApiException) {
      throw error;
    }
    
    debugPrint('Erro de conexão com a região $_currentRegion: $error');
    
    // Tenta encontrar uma região com menor latência
    try {
      final newRegion = await MultiRegionConfig.findLowestLatencyRegion();
      
      // Se encontrou uma região diferente, tenta novamente
      if (newRegion != _currentRegion) {
        debugPrint('Fazendo fallback para a região $newRegion');
        await changeRegion(newRegion);
        return retryCallback();
      }
    } catch (e) {
      debugPrint('Erro ao buscar região alternativa: $e');
    }
    
    // Se não conseguiu fazer fallback, propaga o erro original
    throw error;
  }
  
  /// Extrai a mensagem de erro da resposta
  String _parseErrorMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      return data['message'] ?? data['error'] ?? 'Erro desconhecido';
    } catch (e) {
      return response.body;
    }
  }
}

/// Exceção para erros de API
class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({required this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}