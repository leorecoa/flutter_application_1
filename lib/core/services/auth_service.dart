class AuthService {
  static bool _isAuthenticated = false;
  static String _userId = '';
  static String _accessToken = '';
  
  // Ignorando aviso de campo não utilizado, pois será usado em implementações futuras
  // ignore: unused_field
  static String _refreshToken = '';
  
  static bool get isAuthenticated => _isAuthenticated;
  static String get userId => _userId;

  Future<bool> isSignedIn() async {
    return _isAuthenticated;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return {
      'success': true,
      'user': {'email': email}
    };
  }

  Future<Map<String, String>> getAuthHeaders() async {
    return {'Authorization': 'Bearer $_accessToken'};
  }

  Future<void> refreshAccessToken() async {}

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    return signIn(email, password);
  }
  
  // Método estático para login (para testes)
  static Future<bool> login(String email, String password) async {
    try {
      // Simula validação de senha
      if (password == 'wrong_password') {
        return false;
      }
      
      _isAuthenticated = true;
      _userId = 'user-123';
      _accessToken = 'test_token';
      _refreshToken = 'refresh_token';
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Método estático para logout (para testes)
  static Future<void> logout() async {
    _isAuthenticated = false;
    _userId = '';
    _accessToken = '';
    _refreshToken = '';
  }

  static Map<String, dynamic>? getCurrentUser() {
    return _isAuthenticated ? {'id': _userId, 'token': _accessToken} : null;
  }
}