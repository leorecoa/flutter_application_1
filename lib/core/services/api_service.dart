import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

/// Serviço para API
class ApiService {
  String? _authToken;
  User? _currentUser;

  /// Provider para o serviço API
  static final provider = Provider<ApiService>((ref) {
    return ApiService();
  });

  /// Define o token de autenticação e usuário atual
  void setAuthToken(String token, User user) {
    _authToken = token;
    _currentUser = user;
  }

  /// Obtém o token de autenticação atual
  String? get authToken => _authToken;

  /// Obtém o usuário atual
  User? get currentUser => _currentUser;

  /// Executa uma requisição GET
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true, 'data': []};
  }

  /// Executa uma requisição POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic body,
    String? token,
  }) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));

    // Simula resposta de login
    if (endpoint == '/auth/login') {
      return {
        'success': true,
        'user': {
          'id': '1',
          'name': 'Usuário Teste',
          'email': 'teste@exemplo.com',
        },
        'token': 'mock_token_123',
      };
    }

    return {'success': true, 'data': {}};
  }

  /// Executa uma requisição PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic body,
    String? token,
  }) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true, 'data': {}};
  }

  /// Executa uma requisição DELETE
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true, 'message': 'Deleted successfully'};
  }
}
