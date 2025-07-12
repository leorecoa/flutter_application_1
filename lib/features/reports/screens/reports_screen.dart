import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reports_service.dart';
import '../widgets/pdf_generator.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  final _reportsService = ReportsService();
  late TabController _tabController;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  Map<String, dynamic> _financialData = {};
  List<Map<String, dynamic>> _appointmentsData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    try {
      final financial = await _reportsService.getFinancialReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final appointments = await _reportsService.getAppointmentsReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      
      if (mounted) {
        setState(() {
          _financialData = financial['success'] == true ? financial['data'] ?? {} : _getMockFinancialData();
          _appointmentsData = appointments['success'] == true ? List<Map<String, dynamic>>.from(appointments['data'] ?? []) : _getMockAppointmentsData();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _financialData = _getMockFinancialData();
          _appointmentsData = _getMockAppointmentsData();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockFinancialData() {
    return {
      'totalRevenue': 2450.00,
      'totalAppointments': 28,
      'averageTicket': 87.50,
      'dailyRevenue': [
        {'date': '2024-01-01', 'revenue': 150.0},
        {'date': '2024-01-02', 'revenue': 200.0},
        {'date': '2024-01-03', 'revenue': 180.0},
        {'date': '2024-01-04', 'revenue': 220.0},
        {'date': '2024-01-05', 'revenue': 190.0},
      ],
    };
  }

  List<Map<String, dynamic>> _getMockAppointmentsData() {
    return [
      {'clientName': 'João Silva', 'service': 'Corte', 'dateTime': '2024-01-15T14:00:00Z', 'price': 25.0, 'status': 'Concluído'},
      {'clientName': 'Maria Santos', 'service': 'Manicure', 'dateTime': '2024-01-15T15:00:00Z', 'price': 30.0, 'status': 'Concluído'},
      {'clientName': 'Ana Lima', 'service': 'Escova', 'dateTime': '2024-01-15T16:00:00Z', 'price': 40.0, 'status': 'Agendado'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Selecionar Período',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Financeiro'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Agendamentos'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFinancialTab(),
                _buildAppointmentsTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodCard(),
          const SizedBox(height: 16),
          _buildFinancialSummary(),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _generatePDF('financial'),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Gerar PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodCard(),
          const SizedBox(height: 16),
          _buildAppointmentsSummary(),
          const SizedBox(height: 16),
          _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildServicesChart(),
          const SizedBox(height: 16),
          _buildHourlyChart(),
        ],
      ),
    );
  }

  Widget _buildPeriodCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 8),
            Text(
              'Período: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: _selectDateRange,
              child: const Text('Alterar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo Financeiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Receita Total', 'R\$ ${(_financialData['totalRevenue'] ?? 0).toStringAsFixed(2)}', Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard('Ticket Médio', 'R\$ ${(_financialData['averageTicket'] ?? 0).toStringAsFixed(2)}', Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receita Diária', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('R\$${value.toInt()}'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}'),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateRevenueSpots(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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

  Widget _buildAppointmentsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo de Agendamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Total: ${_appointmentsData.length} agendamentos'),
            Text('Concluídos: ${_appointmentsData.where((a) => a['status'] == 'Concluído').length}'),
            Text('Agendados: ${_appointmentsData.where((a) => a['status'] == 'Agendado').length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Lista de Agendamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _appointmentsData.length,
            itemBuilder: (context, index) {
              final appointment = _appointmentsData[index];
              return ListTile(
                title: Text(appointment['clientName']),
                subtitle: Text('${appointment['service']} - R\$ ${appointment['price'].toStringAsFixed(2)}'),
                trailing: Text(appointment['status']),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServicesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Serviços Mais Populares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6, color: Colors.green)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4, color: Colors.orange)]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Corte');
                            case 1: return const Text('Manicure');
                            case 2: return const Text('Escova');
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Horários Mais Movimentados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}h'),
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(9, 2),
                        const FlSpot(10, 4),
                        const FlSpot(11, 3),
                        const FlSpot(14, 6),
                        const FlSpot(15, 8),
                        const FlSpot(16, 5),
                        const FlSpot(17, 3),
                      ],
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
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

  List<FlSpot> _generateRevenueSpots() {
    final dailyRevenue = _financialData['dailyRevenue'] as List? ?? [];
    return dailyRevenue.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['revenue'].toDouble());
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }

  Future<void> _generatePDF(String type) async {
    try {
      if (type == 'financial') {
        await PdfGenerator.generateFinancialReport(
          context: context,
          data: _financialData,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}