import 'package:flutter/material.dart';
import '../../../core/widgets/loading_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = '30 dias';
  
  final Map<String, dynamic> _analytics = {
    'totalRevenue': 15420.50,
    'totalAppointments': 156,
    'totalClients': 89,
    'averageTicket': 98.85,
    'conversionRate': 78.5,
    'monthlyGrowth': 23.4,
    'topServices': [
      {'name': 'Corte Masculino', 'count': 45, 'revenue': 2250.0},
      {'name': 'Escova', 'count': 32, 'revenue': 1920.0},
      {'name': 'Coloração', 'count': 28, 'revenue': 4200.0},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7 dias', child: Text('Últimos 7 dias')),
              const PopupMenuItem(value: '30 dias', child: Text('Últimos 30 dias')),
              const PopupMenuItem(value: '90 dias', child: Text('Últimos 90 dias')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Carregando analytics...')
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKPICards(),
                    const SizedBox(height: 24),
                    _buildTopServices(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard('Receita Total', 'R\$ ${_analytics['totalRevenue'].toStringAsFixed(2).replaceAll('.', ',')}', Icons.attach_money, Colors.green),
        _buildKPICard('Agendamentos', '${_analytics['totalAppointments']}', Icons.calendar_today, Colors.blue),
        _buildKPICard('Clientes', '${_analytics['totalClients']}', Icons.people, Colors.orange),
        _buildKPICard('Ticket Médio', 'R\$ ${_analytics['averageTicket'].toStringAsFixed(2).replaceAll('.', ',')}', Icons.receipt, Colors.purple),
        _buildKPICard('Taxa Conversão', '${_analytics['conversionRate']}%', Icons.trending_up, Colors.teal),
        _buildKPICard('Crescimento', '+${_analytics['monthlyGrowth']}%', Icons.show_chart, Colors.indigo),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTopServices() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Serviços Mais Populares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...(_analytics['topServices'] as List).map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('${service['count']} agendamentos', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('R\$ ${service['revenue'].toStringAsFixed(2).replaceAll('.', ',')}', 
                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}