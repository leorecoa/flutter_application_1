import 'package:flutter/foundation.dart';
import '../../../core/models/appointment_model.dart';

/// Utilitário para processamento de exportação em background
class BackgroundExportUtils {
  /// Processa a exportação de agendamentos em um isolate separado
  static Future<String> exportInBackground(List<Appointment> appointments) {
    return compute(_exportAppointments, appointments);
  }

  /// Método estático para ser executado em um isolate separado
  static String _exportAppointments(List<Appointment> appointments) {
    final buffer = StringBuffer();

    // Cabeçalho do CSV
    buffer.writeln(
      'ID,Cliente,Serviço,Data,Hora,Status,Valor,Confirmado pelo Cliente',
    );

    // Dados
    for (final appointment in appointments) {
      final dateTime = appointment.dateTime;
      final date =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      final time =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

      buffer.writeln(
        [
          appointment.id,
          _escapeCsvField(appointment.clientName),
          _escapeCsvField(appointment.service),
          date,
          time,
          _getStatusText(appointment.status),
          appointment.price.toStringAsFixed(2).replaceAll('.', ','),
          appointment.confirmedByClient ? 'Sim' : 'Não',
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Escapa campos CSV para evitar problemas com vírgulas e aspas
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Converte o status para texto
  static String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Não Compareceu';
      default:
        return 'Desconhecido';
    }
  }

  /// Processa exportação em chunks para grandes volumes de dados
  static Future<List<String>> exportInChunks(
    List<Appointment> appointments, {
    int chunkSize = 500,
  }) async {
    final chunks = <List<Appointment>>[];

    for (var i = 0; i < appointments.length; i += chunkSize) {
      final end = (i + chunkSize < appointments.length)
          ? i + chunkSize
          : appointments.length;
      chunks.add(appointments.sublist(i, end));
    }

    final results = <String>[];
    for (final chunk in chunks) {
      final result = await compute(_exportAppointments, chunk);
      results.add(result);
    }

    return results;
  }
}
