import '../../../core/models/appointment_model.dart';
import '../../../core/models/paginated_response_model.dart';

/// Interface para o serviço de agendamentos
///
/// Define o contrato que qualquer implementação de serviço de agendamentos deve seguir.
/// Isso facilita a substituição da implementação real por mocks em testes.
abstract class IAppointmentsService {
  /// Cria um novo agendamento
  Future<Map<String, dynamic>> createAppointment({
    required String professionalId,
    required String serviceId,
    required DateTime appointmentDateTime,
    required String clientName,
    required String clientPhone,
    required String service,
    required double price,
    String? notes,
    String? clientId,
    int? duration,
  });

  /// Busca um agendamento pelo ID
  Future<Map<String, dynamic>> getAppointmentById(String appointmentId);
  
  /// Busca agendamentos com filtros
  Future<Map<String, dynamic>> getAppointments({
    String? status, 
    DateTime? date,
    String? clientId,
    int? limit,
    String? lastKey,
    String? search,
  });
  
  /// Verifica conflito de horário para um novo agendamento
  Future<bool> checkTimeConflict(DateTime appointmentDateTime, int durationMinutes);

  /// Atualiza apenas o status de um agendamento
  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  );

  /// Atualiza um agendamento completo
  Future<Map<String, dynamic>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> appointmentData,
  );

  /// Exclui um agendamento
  Future<Map<String, dynamic>> deleteAppointment(String appointmentId);

  /// Busca agendamentos com paginação e filtros
  Future<PaginatedResponse<Appointment>> getAppointmentsList({
    Map<String, dynamic>? filters,
    int limit = 20,
    String? lastKey,
    String? searchTerm,
  });
  
  /// Busca agendamentos de um cliente específico
  Future<List<Appointment>> getClientAppointments(String clientId);

  /// Cria um modelo de agendamento
  Future<Appointment> createAppointmentModel({
    required String professionalId,
    required String serviceId,
    required DateTime appointmentDateTime,
    required String clientName,
    required String clientPhone,
    required String service,
    required double price,
    String? notes,
    String? clientId,
    int? duration,
  });
}