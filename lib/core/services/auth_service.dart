class AuthService {
  static bool get isAuthenticated => false;
  static String get userId => 'user-123';

  Future<bool> isSignedIn() async {
    return false;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return {
      'success': true,
      'user': {'email': email}
    };
  }

  Future<Map<String, String>> getAuthHeaders() async {
    return {'Authorization': 'Bearer token'};
  }

  Future<void> refreshAccessToken() async {}

  Future<Map<String, dynamic>> login(String email, String password) async {
    return signIn(email, password);
  }

  static Map<String, dynamic>? getCurrentUser() {
    return null;
  }
}