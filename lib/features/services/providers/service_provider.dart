import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/services');
      
      if (response['success'] == true) {
        final List<dynamic> servicesData = response['data'] ?? [];
        _services = servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Erro ao carregar serviços';
        _services = [];
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _services = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/services', serviceData);
      
      if (response['success'] == true) {
        await loadServices(); // Reload services
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao criar serviço';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/services/$serviceId', serviceData);
      
      if (response['success'] == true) {
        await loadServices(); // Reload services
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao atualizar serviço';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.delete('/services/$serviceId');
      
      if (response['success'] == true) {
        await loadServices(); // Reload services
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao excluir serviço';
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}