import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/appointment_model.dart';
import 'appointment_status_utils.dart';

/// Utilitário para exportar agendamentos para CSV
class AppointmentExportUtils {
  /// Exporta uma lista de agendamentos para um arquivo CSV e compartilha
  static Future<void> exportToCsv(List<Appointment> appointments) async {
    try {
      // Criar conteúdo CSV
      final csvContent = _generateCsvContent(appointments);
      
      // Obter diretório temporário
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/agendamentos_$dateStr.csv';
      
      // Escrever arquivo
      final file = File(filePath);
      await file.writeAsString(csvContent);
      
      // Compartilhar arquivo
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Agendamentos AGENDEMAIS',
        text: 'Relatório de agendamentos exportado em $dateStr',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gera o conteúdo CSV a partir da lista de agendamentos
  static String _generateCsvContent(List<Appointment> appointments) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final buffer = StringBuffer();
    
    // Cabeçalho
    buffer.writeln('ID,Cliente,Telefone,Serviço,Preço,Data,Status,Duração,Notas');
    
    // Linhas de dados
    for (final appointment in appointments) {
      final formattedDate = dateFormat.format(appointment.dateTime);
      final status = AppointmentStatusUtils.getStatusText(appointment.status);
      
      // Escapar campos que podem conter vírgulas
      final clientName = _escapeCsvField(appointment.clientName);
      final service = _escapeCsvField(appointment.service);
      final notes = _escapeCsvField(appointment.notes ?? '');
      
      buffer.writeln(
        '${appointment.id},$clientName,${appointment.clientPhone},$service,'
        '${appointment.price.toStringAsFixed(2)},$formattedDate,$status,'
        '${appointment.duration},$notes'
      );
    }
    
    return buffer.toString();
  }
  
  /// Escapa campos CSV que podem conter vírgulas ou aspas
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Substituir aspas duplas por duas aspas duplas e envolver em aspas
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}