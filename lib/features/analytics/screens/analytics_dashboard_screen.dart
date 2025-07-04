import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/report_model.dart';
import '../services/analytics_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;
  ReportModel? _revenueReport;
  ReportModel? _appointmentsReport;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DateTime now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month, now.day - 7);
      final DateTime endDate = DateTime(now.year, now.month, now.day);

      final revenueReport = await AnalyticsService.generateReport(
        type: ReportType.weekly,
        category: ReportCategory.revenue,
        startDate: startDate,
        endDate: endDate,
      );

      final appointmentsReport = await AnalyticsService.generateReport(
        type: ReportType.weekly,
        category: ReportCategory.appointments,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _revenueReport = revenueReport;
          _appointmentsReport = appointmentsReport;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar relatórios: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analítico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRevenueCard(),
                    const SizedBox(height: 16),
                    _buildAppointmentsCard(),
                    const SizedBox(height: 16),
                    _buildReportsList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de geração de relatórios
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRevenueCard() {
    if (_revenueReport == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Dados de receita não disponíveis'),
        ),
      );
    }

    final data = _revenueReport!.data;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final byDay =
        (data['byDay'] as Map<String, dynamic>).cast<String, double>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Receita',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatter.format(data['total']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Média diária: ${formatter.format(data['average'])}'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= byDay.length ||
                              value.toInt() < 0) {
                            return const SizedBox();
                          }
                          final date = DateTime.parse(
                              byDay.keys.elementAt(value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        byDay.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          byDay.values.elementAt(index),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withAlpha(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsCard() {
    if (_appointmentsReport == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Dados de agendamentos não disponíveis'),
        ),
      );
    }

    final data = _appointmentsReport!.data;
    final byDay = (data['byDay'] as Map<String, dynamic>).cast<String, int>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agendamentos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${data['total']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusIndicator(
                  'Concluídos',
                  data['completed'],
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatusIndicator(
                  'Cancelados',
                  data['cancelled'],
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= byDay.length ||
                              value.toInt() < 0) {
                            return const SizedBox();
                          }
                          final date = DateTime.parse(
                              byDay.keys.elementAt(value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    byDay.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: byDay.values.elementAt(index).toDouble(),
                          color: Colors.blue,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $value'),
      ],
    );
  }

  Widget _buildReportsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relatórios Recentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ReportModel>>(
              future: AnalyticsService.getRecentReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Erro ao carregar relatórios: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhum relatório encontrado'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final report = snapshot.data![index];
                    return ListTile(
                      title: Text(_getReportTitle(report)),
                      subtitle: Text(
                        '${DateFormat('dd/MM/yyyy').format(report.startDate)} - '
                        '${DateFormat('dd/MM/yyyy').format(report.endDate)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navegar para detalhes do relatório
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getReportTitle(ReportModel report) {
    String categoryName = '';
    switch (report.category) {
      case ReportCategory.revenue:
        categoryName = 'Receita';
        break;
      case ReportCategory.appointments:
        categoryName = 'Agendamentos';
        break;
      case ReportCategory.clients:
        categoryName = 'Clientes';
        break;
      case ReportCategory.services:
        categoryName = 'Serviços';
        break;
    }

    String typeName = '';
    switch (report.type) {
      case ReportType.daily:
        typeName = 'Diário';
        break;
      case ReportType.weekly:
        typeName = 'Semanal';
        break;
      case ReportType.monthly:
        typeName = 'Mensal';
        break;
      case ReportType.custom:
        typeName = 'Personalizado';
        break;
    }

    return 'Relatório $typeName de $categoryName';
  }
}
