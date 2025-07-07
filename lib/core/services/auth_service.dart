import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _apiService = ApiService();
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(AppConstants.authTokenKey);
      _refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      
      final userData = prefs.getString(AppConstants.userDataKey);
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
      }

      // Verificar se o token ainda é válido
      if (_accessToken != null && _currentUser != null) {
        final isValid = await _validateToken();
        if (!isValid) {
          await clearAuthToken();
        }
      }
    } catch (e) {
      debugPrint('Erro ao inicializar AuthService: $e');
      await clearAuthToken();
    }
  }

  Future<bool> _validateToken() async {
    try {
      final response = await _apiService.get('/auth/validate');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      if (response['success'] == true) {
        final data = response['data'];
        _accessToken = data['accessToken'];
        _refreshToken = data['refreshToken'];
        _currentUser = User.fromJson(data['user']);

        await _saveTokens();
        
        return {
          'success': true, 
          'message': 'Login realizado com sucesso',
          'user': _currentUser!.toJson(),
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Credenciais inválidas'
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (phone != null) 'phone': phone.trim(),
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Conta criada com sucesso! Verifique seu email.',
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Erro ao criar conta'
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  Future<Map<String, dynamic>> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final response = await _apiService.post('/auth/confirm', {
        'email': email.trim().toLowerCase(),
        'confirmationCode': confirmationCode.trim(),
      });

      return {
        'success': response['success'] == true,
        'message': response['message'] ?? (
          response['success'] == true 
            ? 'Email confirmado com sucesso!' 
            : 'Código de confirmação inválido'
        ),
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', {
        'email': email.trim().toLowerCase(),
      });

      return {
        'success': response['success'] == true,
        'message': response['message'] ?? (
          response['success'] == true 
            ? 'Código de recuperação enviado para seu email' 
            : 'Email não encontrado'
        ),
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', {
        'email': email.trim().toLowerCase(),
        'confirmationCode': confirmationCode.trim(),
        'newPassword': newPassword,
      });

      return {
        'success': response['success'] == true,
        'message': response['message'] ?? (
          response['success'] == true 
            ? 'Senha alterada com sucesso!' 
            : 'Código inválido ou expirado'
        ),
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  Future<void> logout() async {
    try {
      // Notificar o backend sobre o logout
      if (_accessToken != null) {
        await _apiService.post('/auth/logout', {});
      }
    } catch (e) {
      debugPrint('Erro no logout do backend: $e');
    } finally {
      await clearAuthToken();
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _apiService.post('/auth/refresh', {
        'refreshToken': _refreshToken,
      });

      if (response['success'] == true) {
        final data = response['data'];
        _accessToken = data['accessToken'];
        if (data['refreshToken'] != null) {
          _refreshToken = data['refreshToken'];
        }
        
        await _saveTokens();
        return true;
      }

      // Se falhou, limpar tokens
      await clearAuthToken();
      return false;
    } catch (e) {
      debugPrint('Erro ao renovar token: $e');
      await clearAuthToken();
      return false;
    }
  }

  Future<void> clearAuthToken() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  Future<void> _saveTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_accessToken != null) {
        await prefs.setString(AppConstants.authTokenKey, _accessToken!);
      }
      
      if (_refreshToken != null) {
        await prefs.setString(AppConstants.refreshTokenKey, _refreshToken!);
      }
      
      if (_currentUser != null) {
        await prefs.setString(AppConstants.userDataKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      debugPrint('Erro ao salvar tokens: $e');
    }
  }

  // Método para obter token de autenticação (usado pelos serviços)
  Future<String?> getAuthToken() async {
    // Se não tem token em memória, tentar carregar do storage
    if (_accessToken == null) {
      await init();
    }
    
    // Se ainda não tem token, retornar null
    if (_accessToken == null) {
      return null;
    }
    
    // Verificar se o token ainda é válido
    final isValid = await _validateToken();
    if (!isValid) {
      // Tentar renovar o token
      final renewed = await refreshAccessToken();
      if (!renewed) {
        return null;
      }
    }
    
    return _accessToken;
  }

  // Método para atualizar dados do usuário
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (phone != null) updates['phone'] = phone.trim();
      
      if (updates.isEmpty) return true;

      final response = await _apiService.put('/auth/profile', updates);

      if (response['success'] == true) {
        // Atualizar dados locais
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            name: name ?? _currentUser!.name,
            phone: phone ?? _currentUser!.phone,
          );
          await _saveTokens();
        }
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      return false;
    }
  }
}