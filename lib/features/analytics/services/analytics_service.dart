import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/report_model.dart';

class AnalyticsService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/analytics';

  /// Gera um relatório com base nos parâmetros fornecidos
  static Future<ReportModel> generateReport({
    required ReportType type,
    required ReportCategory category,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'type': type.name,
          'category': category.name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ReportModel.fromJson(data);
      } else {
        throw Exception('Falha ao gerar relatório: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return _getMockReport(type, category, startDate, endDate);
    }
  }

  /// Obtém um relatório existente pelo ID
  static Future<ReportModel> getReportById(String reportId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReportModel.fromJson(data);
      } else {
        throw Exception('Falha ao obter relatório: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return _getMockReport(
        ReportType.monthly, 
        ReportCategory.revenue,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );
    }
  }

  /// Obtém lista de relatórios recentes
  static Future<List<ReportModel>> getRecentReports() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/recent'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ReportModel.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao obter relatórios recentes: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return [
        _getMockReport(
          ReportType.daily,
          ReportCategory.appointments,
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now(),
        ),
        _getMockReport(
          ReportType.weekly,
          ReportCategory.revenue,
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        ),
        _getMockReport(
          ReportType.monthly,
          ReportCategory.clients,
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now(),
        ),
      ];
    }
  }

  /// Gera dados simulados para desenvolvimento
  static ReportModel _getMockReport(
    ReportType type,
    ReportCategory category,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<String, dynamic> mockData = {};
    
    switch (category) {
      case ReportCategory.revenue:
        mockData['total'] = 2580.50;
        mockData['average'] = 215.04;
        mockData['byDay'] = {
          '2024-07-01': 350.00,
          '2024-07-02': 420.50,
          '2024-07-03': 280.00,
          '2024-07-04': 510.00,
          '2024-07-05': 320.00,
          '2024-07-06': 450.00,
          '2024-07-07': 250.00,
        };
        mockData['byService'] = {
          'Corte de Cabelo': 1200.00,
          'Barba': 580.50,
          'Coloração': 800.00,
        };
        break;
        
      case ReportCategory.appointments:
        mockData['total'] = 42;
        mockData['completed'] = 38;
        mockData['cancelled'] = 4;
        mockData['byDay'] = {
          '2024-07-01': 5,
          '2024-07-02': 8,
          '2024-07-03': 6,
          '2024-07-04': 7,
          '2024-07-05': 5,
          '2024-07-06': 6,
          '2024-07-07': 5,
        };
        mockData['byBarber'] = {
          'João Silva': 15,
          'Maria Oliveira': 18,
          'Carlos Santos': 9,
        };
        break;
        
      case ReportCategory.clients:
        mockData['total'] = 28;
        mockData['new'] = 5;
        mockData['returning'] = 23;
        mockData['byDay'] = {
          '2024-07-01': 3,
          '2024-07-02': 5,
          '2024-07-03': 4,
          '2024-07-04': 6,
          '2024-07-05': 3,
          '2024-07-06': 4,
          '2024-07-07': 3,
        };
        break;
        
      case ReportCategory.services:
        mockData['total'] = 3;
        mockData['mostPopular'] = 'Corte de Cabelo';
        mockData['byPopularity'] = {
          'Corte de Cabelo': 25,
          'Barba': 12,
          'Coloração': 5,
        };
        break;
    }
    
    return ReportModel(
      id: 'report-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      category: category,
      startDate: startDate,
      endDate: endDate,
      data: mockData,
      generatedAt: DateTime.now(),
    );
  }
}