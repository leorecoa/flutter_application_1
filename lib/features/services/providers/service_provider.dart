import 'package:flutter/foundation.dart';
import '../../../shared/models/service_model.dart';
import '../../../core/services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.get('/services');
      final servicesData = response['data'] as List;
      
      _services = servicesData
          .map((data) => ServiceModel.fromJson(data))
          .toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/services', serviceData);
      final newService = ServiceModel.fromJson(response['data']);
      
      _services.add(newService);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateService(String serviceId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.put('/services/$serviceId', updates);
      final updatedService = ServiceModel.fromJson(response['data']);
      
      final index = _services.indexWhere((service) => service.id == serviceId);
      if (index != -1) {
        _services[index] = updatedService;
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _setLoading(true);
    _clearError();

    try {
      await ApiService.delete('/services/$serviceId');
      
      _services.removeWhere((service) => service.id == serviceId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
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