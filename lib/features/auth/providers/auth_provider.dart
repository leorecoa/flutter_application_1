import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final userData = response['user'];

      ApiService.setAuthToken(token);
      _currentUser = UserModel.fromJson(userData);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String businessName,
    required String businessType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'businessName': businessName,
        'businessType': businessType,
      });

      final token = response['token'];
      final userData = response['user'];

      ApiService.setAuthToken(token);
      _currentUser = UserModel.fromJson(userData);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    ApiService.setAuthToken('');
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}