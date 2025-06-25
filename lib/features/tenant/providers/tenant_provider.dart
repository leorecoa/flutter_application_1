import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class TenantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _tenantConfig;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get tenantConfig => _tenantConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTenant => _tenantConfig != null;

  Future<bool> createTenant(String name, String businessType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/tenants/create', {
        'name': name,
        'businessType': businessType,
      });

      if (response['success'] == true) {
        _tenantConfig = response['data']['tenant'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao criar empresa';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTenantConfig() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/tenants/config');
      
      if (response['success'] == true) {
        _tenantConfig = response['data'];
      } else {
        _error = response['message'] ?? 'Erro ao carregar configurações';
        _tenantConfig = null;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _tenantConfig = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateTenantConfig(Map<String, dynamic> config) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/tenants/config', config);
      
      if (response['success'] == true) {
        _tenantConfig = response['data']['tenant'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao atualizar configurações';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String get primaryColor {
    return _tenantConfig?['theme']?['primaryColor'] ?? '#007bff';
  }

  String? get logoUrl {
    return _tenantConfig?['theme']?['logoUrl'];
  }

  String get tenantName {
    return _tenantConfig?['name'] ?? 'Minha Empresa';
  }
}