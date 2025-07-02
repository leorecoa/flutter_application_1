class AuthService {
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty;
  }
  
  static Future<bool> signup(Map<String, String> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}