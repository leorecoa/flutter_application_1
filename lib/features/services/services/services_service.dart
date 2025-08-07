import '../../../core/services/api_service.dart';
import '../../../core/models/service_model.dart';

class ServicesService {
  final _apiService = ApiService();

  Future<List<Service>> getServices() async {
    final response = await _apiService.get('/services');
    // Implementação temporária
    return [
      const Service(
        id: '1',
        name: 'Corte de Cabelo',
        duration: 30,
        price: 50.0,
        description: 'Corte de cabelo masculino',
      ),
      const Service(
        id: '2',
        name: 'Manicure',
        duration: 60,
        price: 30.0,
        description: 'Manicure completa',
      ),
    ];
  }

  /// Cria um modelo de serviço
  Service createServiceModel({
    required String name,
    required int duration,
    required double price,
    String? description,
  }) {
    return Service(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      duration: duration,
      price: price,
      description: description,
    );
  }

  Future<Service> createService(Service service) async {
    final response = await _apiService.post(
      '/services',
      body: service.toJson(),
    );
    // Implementação temporária
    return service;
  }

  Future<Service> updateService(Service service) async {
    final response = await _apiService.put(
      '/services/${service.id}',
      body: service.toJson(),
    );
    // Implementação temporária
    return service;
  }

  Future<bool> deleteService(String serviceId) async {
    final response = await _apiService.delete('/services/$serviceId');
    // Implementação temporária
    return true;
  }
}
