import 'package:flutter_application_1/core/services/api_service.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';

/// Interface do repositório de agendamentos
abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  });
}

/// Implementação do repositório de agendamentos
class AppointmentRepositoryImpl implements AppointmentRepository {
  final ApiService _apiService;

  AppointmentRepositoryImpl(this._apiService);

  @override
  Future<List<Appointment>> getAppointments({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    // Implementação temporária
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'service1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        clientName: 'João Silva',
        clientPhone: '11999999999',
        serviceName: 'Corte de Cabelo',
        price: 50.0,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
