import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Implementação local do AuthService para desenvolvimento sem AWS
class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  User? _currentUser;
  String? _accessToken;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;

  /// Inicializa o serviço de autenticação
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('local_access_token');

    final userData = prefs.getString('local_user_data');
    if (userData != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
      } catch (e) {
        // Se houver erro, limpa os dados corrompidos
        await _clearLocalData();
      }
    }
  }

  /// Realiza login local (simulado)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simula delay de rede
      await Future.delayed(const Duration(milliseconds: 800));

      // Validação básica
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email e senha são obrigatórios'};
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Senha deve ter pelo menos 6 caracteres',
        };
      }

      // Simula usuário local
      _currentUser = User(
        id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        businessName: 'Meu Negócio',
        phone: '(11) 99999-9999',
        createdAt: DateTime.now(),
        isActive: true,
      );

      _accessToken = 'local-token-${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      await _saveLocalData();

      return {
        'success': true,
        'message': 'Login realizado com sucesso',
        'user': _currentUser!.toJson(),
        'accessToken': _accessToken,
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro interno: $e'};
    }
  }

  /// Registra novo usuário local
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Todos os campos são obrigatórios',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Senha deve ter pelo menos 6 caracteres',
        };
      }

      // Simula criação de usuário
      _currentUser = User(
        id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        businessName: 'Meu Negócio',
        phone: '(11) 99999-9999',
        createdAt: DateTime.now(),
        isActive: true,
      );

      _accessToken = 'local-token-${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      await _saveLocalData();

      return {
        'success': true,
        'message': 'Usuário registrado com sucesso',
        'user': _currentUser!.toJson(),
        'accessToken': _accessToken,
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro interno: $e'};
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    _currentUser = null;
    _accessToken = null;
    _isAuthenticated = false;

    await _clearLocalData();
  }

  /// Verifica se o token ainda é válido
  Future<bool> isTokenValid() async {
    return _isAuthenticated && _accessToken != null;
  }

  /// Salva dados localmente
  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    if (_accessToken != null) {
      await prefs.setString('local_access_token', _accessToken!);
    }

    if (_currentUser != null) {
      await prefs.setString(
        'local_user_data',
        jsonEncode(_currentUser!.toJson()),
      );
    }
  }

  /// Limpa dados locais
  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_access_token');
    await prefs.remove('local_user_data');
  }

  /// Atualiza dados do usuário
  Future<void> updateUserData(User user) async {
    _currentUser = user;
    await _saveLocalData();
  }
}
