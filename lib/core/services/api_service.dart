import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _authToken;
  
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.authTokenKey);
  }
  
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
  }
  
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
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
      return {
        'success': true,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': email,
          'name': email.split('@')[0],
        },
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
    return {
      'success': true,
      'data': {
        'appointmentsToday': 12,
        'totalClients': 248,
        'monthlyRevenue': 15420.50,
        'activeServices': 8,
        'weeklyGrowth': 12.5,
        'satisfactionRate': 4.8,
      }
    };
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