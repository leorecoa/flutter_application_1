import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import '../logging/logger.dart';
import '../config/environment_config.dart';
import 'api_interceptor.dart';
import 'local_cache_service.dart';

/// Provider para o serviço de API
final apiServiceProvider = Provider<ApiService>((ref) {
  final interceptor = ref.watch(apiInterceptorProvider);
  final cacheService = ref.watch(localCacheServiceProvider);
  return ApiServiceImpl(interceptor, cacheService);
});

/// Interface para o serviço de API
abstract class ApiService {
  /// Realiza uma requisição GET
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers});
  
  /// Realiza uma requisição POST
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers});
  
  /// Realiza uma requisição PUT
  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers});
  
  /// Realiza uma requisição DELETE
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers});
  
  /// Define a URL base da API
  void setBaseUrl(String baseUrl);
  
  /// Define o token de autenticação
  void setAuthToken(String token);
}

/// Implementação do serviço de API
class ApiServiceImpl implements ApiService {
  ApiServiceImpl(this._interceptor, this._cacheService);
  
  final ApiInterceptor _interceptor;
  final LocalCacheService _cacheService;
  String _baseUrl = EnvironmentConfig.apiEndpoint;
  String? _authToken;
  
  @override
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }
  
  @override
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  @override
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final cacheKey = '${uri.toString()}_GET';
      
      // Verifica se a resposta está em cache e se podemos usar cache
      if (EnvironmentConfig.minimizeApiCalls && _cacheService.containsKey(cacheKey)) {
        final cachedData = _cacheService.get<dynamic>(cacheKey);
        Logger.debug('Usando resposta em cache', context: {
          'endpoint': endpoint,
          'cacheKey': cacheKey,
        });
        return cachedData;
      }
      
      final requestHeaders = _buildHeaders(headers);
      
      // Intercepta a requisição
      final interceptedRequest = await _interceptor.onRequest(
        'GET',
        uri,
        headers: requestHeaders,
      );
      
      // Executa a requisição
      final startTime = DateTime.now();
      final response = await http.get(interceptedRequest.uri, headers: interceptedRequest.headers);
      final endTime = DateTime.now();
      
      // Intercepta a resposta
      final interceptedResponse = await _interceptor.onResponse(
        'GET',
        uri,
        response,
        startTime: startTime,
        endTime: endTime,
      );
      
      final processedResponse = _processResponse(interceptedResponse);
      
      // Armazena a resposta em cache
      if (EnvironmentConfig.minimizeApiCalls) {
        _cacheService.set(cacheKey, processedResponse);
      }
      
      return processedResponse;
    } catch (e) {
      // Intercepta o erro
      final error = await _interceptor.onError('GET', Uri.parse('$_baseUrl/$endpoint'), e);
      throw error;
    }
  }
  
  @override
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint);
      final requestHeaders = _buildHeaders(headers);
      final encodedBody = body != null ? json.encode(body) : null;
      
      // Intercepta a requisição
      final interceptedRequest = await _interceptor.onRequest(
        'POST',
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );
      
      // Executa a requisição
      final startTime = DateTime.now();
      final response = await http.post(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      );
      final endTime = DateTime.now();
      
      // Intercepta a resposta
      final interceptedResponse = await _interceptor.onResponse(
        'POST',
        uri,
        response,
        startTime: startTime,
        endTime: endTime,
      );
      
      return _processResponse(interceptedResponse);
    } catch (e) {
      // Intercepta o erro
      final error = await _interceptor.onError('POST', Uri.parse('$_baseUrl/$endpoint'), e);
      throw error;
    }
  }
  
  @override
  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint);
      final requestHeaders = _buildHeaders(headers);
      final encodedBody = body != null ? json.encode(body) : null;
      
      // Intercepta a requisição
      final interceptedRequest = await _interceptor.onRequest(
        'PUT',
        uri,
        headers: requestHeaders,
        body: encodedBody,
      );
      
      // Executa a requisição
      final startTime = DateTime.now();
      final response = await http.put(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      );
      final endTime = DateTime.now();
      
      // Intercepta a resposta
      final interceptedResponse = await _interceptor.onResponse(
        'PUT',
        uri,
        response,
        startTime: startTime,
        endTime: endTime,
      );
      
      return _processResponse(interceptedResponse);
    } catch (e) {
      // Intercepta o erro
      final error = await _interceptor.onError('PUT', Uri.parse('$_baseUrl/$endpoint'), e);
      throw error;
    }
  }
  
  @override
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint);
      final requestHeaders = _buildHeaders(headers);
      
      // Intercepta a requisição
      final interceptedRequest = await _interceptor.onRequest(
        'DELETE',
        uri,
        headers: requestHeaders,
      );
      
      // Executa a requisição
      final startTime = DateTime.now();
      final response = await http.delete(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
      );
      final endTime = DateTime.now();
      
      // Intercepta a resposta
      final interceptedResponse = await _interceptor.onResponse(
        'DELETE',
        uri,
        response,
        startTime: startTime,
        endTime: endTime,
      );
      
      return _processResponse(interceptedResponse);
    } catch (e) {
      // Intercepta o erro
      final error = await _interceptor.onError('DELETE', Uri.parse('$_baseUrl/$endpoint'), e);
      throw error;
    }
  }
  
  /// Constrói a URI para a requisição
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final uri = Uri.parse('$_baseUrl/$normalizedEndpoint');
    
    if (queryParams != null) {
      return uri.replace(
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
      );
    }
    
    return uri;
  }
  
  /// Constrói os headers para a requisição
  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
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
  
  /// Processa a resposta da requisição
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body.isNotEmpty ? json.decode(response.body) : null;
    
    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      throw AuthException(
        AuthErrorType.sessionExpired,
        'Sessão expirada ou inválida',
      );
    } else if (statusCode == 403) {
      throw UnauthorizedException('Acesso negado');
    } else if (statusCode == 404) {
      throw NotFoundException('Recurso não encontrado');
    } else if (statusCode >= 400 && statusCode < 500) {
      final message = responseBody?['message'] ?? 'Erro na requisição';
      throw ServerException(statusCode, message);
    } else if (statusCode >= 500) {
      throw ServerException(statusCode, 'Erro interno do servidor');
    } else {
      throw ServerException(statusCode, 'Erro desconhecido');
    }
  }
}