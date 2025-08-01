import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface para o repositório de agendamentos
abstract class AppointmentRepository {
  /// Provider para o repositório de agendamentos
  static final provider = Provider<AppointmentRepository>((ref) {
    throw UnimplementedError('Implemente este provider na camada de dados');
  });

  /// Busca agendamentos com paginação e filtros
  Future<List<dynamic>> getAppointments({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  });

  /// Atualiza um agendamento existente
  Future<dynamic> updateAppointment(dynamic appointment);

  /// Atualiza o status de um agendamento
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus);

  /// Exclui um agendamento
  Future<void> deleteAppointment(String appointmentId);

  /// Cria múltiplos agendamentos recorrentes
  Future<List<dynamic>> createRecurringAppointments(List<dynamic> appointments);

  /// Exporta agendamentos para o formato especificado
  Future<String> exportAppointments({required String format});
}