import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _authToken;
  User? _currentUser;
  
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }
  
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (path == '/auth/login') {
        return _mockLogin(data);
      }
      
      if (path == '/auth/register') {
        return _mockRegister(data);
      }
      
      return {'success': true, 'message': 'Operação realizada'};
    } catch (e) {
      return {'success': false, 'message': 'Erro na requisição'};
    }
  }
  
  Map<String, dynamic> _mockLogin(Map<String, dynamic> data) {
    final email = data['email']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';
    
    if (email.contains('@') && password.length >= AppConstants.minPasswordLength) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        businessName: 'Minha Empresa',
        phone: '(11) 99999-9999',
        createdAt: DateTime.now(),
      );
      
      return {
        'success': true,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': user.toJson(),
        'message': 'Login realizado com sucesso'
      };
    }
    
    return {'success': false, 'message': 'Credenciais inválidas'};
  }
  
  Map<String, dynamic> _mockRegister(Map<String, dynamic> data) {
    final email = data['email']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';
    final name = data['name']?.toString() ?? '';
    
    if (email.contains('@') && password.length >= AppConstants.minPasswordLength && name.isNotEmpty) {
      return {'success': true, 'message': 'Conta criada com sucesso!'};
    }
    
    return {'success': false, 'message': 'Dados inválidos'};
  }
  
  Future<Map<String, dynamic>> get(String path) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (path == '/dashboard/stats') {
        return _mockDashboardStats();
      }
      
      return {'success': true, 'data': {}};
    } catch (e) {
      return {'success': false, 'message': 'Erro na requisição'};
    }
  }
  
  Map<String, dynamic> _mockDashboardStats() {
    final now = DateTime.now();
    return {
      'success': true,
      'data': {
        'appointmentsToday': now.day % 15 + 5,
        'totalClients': now.month * 25 + 150,
        'monthlyRevenue': (now.month * 2500.0) + 8000.0,
        'activeServices': 12,
        'weeklyGrowth': (now.day % 25) + 8.0,
        'satisfactionRate': 4.6 + (now.millisecond % 4) / 10,
        'nextAppointments': _getMockAppointments(),
      }
    };
  }
  
  List<Map<String, dynamic>> _getMockAppointments() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'clientName': 'Maria Silva',
        'service': 'Corte + Escova',
        'dateTime': now.add(const Duration(hours: 2)).toIso8601String(),
        'price': 80.0,
        'status': 'confirmed',
      },
      {
        'id': '2',
        'clientName': 'João Santos',
        'service': 'Barba',
        'dateTime': now.add(const Duration(hours: 4)).toIso8601String(),
        'price': 35.0,
        'status': 'scheduled',
      },
    ];
  }
  
  Future<Map<String, dynamic>> generatePix({
    required double valor,
    required String descricao,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'pixCode': '00020126580014br.gov.bcb.pix0136${DateTime.now().millisecondsSinceEpoch}520400005303986540${valor.toStringAsFixed(2)}5802BR5925AGENDEMAIS LTDA6009SAO PAULO62070503***6304ABCD',
    };
  }
}