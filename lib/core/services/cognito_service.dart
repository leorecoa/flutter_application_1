

import 'aws_cognito_service.dart';

class CognitoService {
  // Usar AWS Cognito real em produção, fallback para teste em desenvolvimento
  static const bool _useRealAWS = bool.fromEnvironment('USE_AWS', defaultValue: false);
  
  // Dados de teste para desenvolvimento
  static String? _currentToken;
  static Map<String, dynamic>? _currentUser;
  
  // Usuários de teste para MVP
  static final Map<String, Map<String, dynamic>> _testUsers = {
    'admin@agendafacil.com': {
      'password': '123456',
      'user': {
        'id': 'admin-001',
        'email': 'admin@agendafacil.com',
        'name': 'Administrador',
        'role': 'admin'
      }
    },
    'barbeiro@agendafacil.com': {
      'password': '123456',
      'user': {
        'id': 'barber-001',
        'email': 'barbeiro@agendafacil.com',
        'name': 'Carlos Silva',
        'role': 'barbeiro'
      }
    }
  };

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (_useRealAWS) {
      return await AWSCognitoService.signIn(email, password);
    } else {
      await Future.delayed(const Duration(seconds: 1));
      
      final testUser = _testUsers[email.toLowerCase()];
      if (testUser != null && testUser['password'] == password) {
        _currentUser = testUser['user'];
        _currentToken = 'jwt-token-${DateTime.now().millisecondsSinceEpoch}';
        
        return {
          'success': true,
          'user': _currentUser,
          'token': _currentToken
        };
      }
      
      return {
        'success': false,
        'error': 'Email ou senha inválidos'
      };
    }
  }

  static Future<void> signOut() async {
    _currentUser = null;
    _currentToken = null;
  }

  static Future<bool> isSignedIn() async {
    return _currentToken != null;
  }
  
  static Map<String, dynamic>? getCurrentUser() => _currentUser;
  static String? getCurrentToken() => _currentToken;
}
