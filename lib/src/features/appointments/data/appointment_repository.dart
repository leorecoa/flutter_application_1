import 'package:agendafacil/src/core/services/api_service.dart';
import 'package:agendafacil/src/features/appointments/data/appointment_model.dart';
import 'package:http/http.dart' as http;

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments(DateTime date);
  Future<void> createAppointment(Appointment appointment);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final ApiService _apiService = ApiService(client: http.Client());

  @override
  Future<List<Appointment>> getAppointments(DateTime date) async {
    // Exemplo de endpoint: /appointments?date=2024-01-15
    final dateString = date.toIso8601String().split('T').first;
    final response = await _apiService.get('appointments?date=$dateString');
    final data = response as List;
    return data.map((item) => Appointment.fromJson(item)).toList();
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    await _apiService.post(
      'appointments',
      body: appointment.toJson(),
    );
  }
}
