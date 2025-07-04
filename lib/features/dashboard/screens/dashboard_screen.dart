import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final response = await _apiService.get('/dashboard/stats');
      if (mounted) {
        setState(() {
          _stats = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dashboard: $e')),
        );
      }
    }
  }

  void _logout() {
    _apiService.clearAuthToken();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: () => context.push('/settings'),
            tooltip: 'Região: ${_apiService.currentRegion}',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visão Geral',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          'Agendamentos Hoje',
                          _stats?['appointmentsToday']?.toString() ?? '0',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Total de Clientes',
                          _stats?['totalClients']?.toString() ?? '0',
                          Icons.people,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Receita do Mês',
                          'R\$ ${_stats?['monthlyRevenue']?.toString() ?? '0,00'}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Serviços Ativos',
                          _stats?['activeServices']?.toString() ?? '0',
                          Icons.build,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Ações Rápidas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildActionButton(
                          'Novo Agendamento',
                          Icons.add_circle,
                          () => _showComingSoon('Novo Agendamento'),
                        ),
                        _buildActionButton(
                          'Gerenciar Clientes',
                          Icons.people_outline,
                          () => _showComingSoon('Gerenciar Clientes'),
                        ),
                        _buildActionButton(
                          'Relatórios',
                          Icons.analytics,
                          () => _showComingSoon('Relatórios'),
                        ),
                        _buildActionButton(
                          'Configurações',
                          Icons.settings,
                          () => _showComingSoon('Configurações'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature em breve!')),
    );
  }
}