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
      await Future.delayed(const Duration(seconds: 1));
      
      final mockStats = {
        'appointmentsToday': 12,
        'totalClients': 248,
        'monthlyRevenue': 15420.50,
        'activeServices': 8,
        'weeklyGrowth': 12.5,
        'satisfactionRate': 4.8,
        'nextAppointment': {
          'client': 'Maria Silva',
          'service': 'Corte + Escova',
          'time': '14:30',
        },
      };
      
      if (mounted) {
        setState(() {
          _stats = mockStats;
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
                          'R\$ ${(_stats?['monthlyRevenue'] ?? 0).toStringAsFixed(2).replaceAll('.', ',')}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Serviços Ativos',
                          _stats?['activeServices']?.toString() ?? '0',
                          Icons.build,
                          Colors.purple,
                        ),
                        _buildStatCard(
                          'Crescimento Semanal',
                          '+${_stats?['weeklyGrowth']?.toString() ?? '0'}%',
                          Icons.trending_up,
                          Colors.teal,
                        ),
                        _buildStatCard(
                          'Satisfação',
                          '${_stats?['satisfactionRate']?.toString() ?? '0'}/5 ⭐',
                          Icons.star,
                          Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_stats?['nextAppointment'] != null) ...[
                      const Text(
                        'Próximo Agendamento',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(_stats!['nextAppointment']['client']),
                          subtitle: Text(_stats!['nextAppointment']['service']),
                          trailing: Text(
                            _stats!['nextAppointment']['time'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                          () => _showNewAppointmentDialog(),
                        ),
                        _buildActionButton(
                          'Gerenciar Clientes',
                          Icons.people_outline,
                          () => _showClientsDialog(),
                        ),
                        _buildActionButton(
                          'Relatórios',
                          Icons.analytics,
                          () => _showReportsDialog(),
                        ),
                        _buildActionButton(
                          'Configurações',
                          Icons.settings,
                          () => context.push('/settings'),
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

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Agendamento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Cliente',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Serviço',
                prefixIcon: Icon(Icons.build),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Data e Hora',
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agendamento criado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showClientsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clientes'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView(
            children: const [
              ListTile(
                leading: CircleAvatar(child: Text('MS')),
                title: Text('Maria Silva'),
                subtitle: Text('(11) 99999-9999'),
                trailing: Icon(Icons.edit),
              ),
              ListTile(
                leading: CircleAvatar(child: Text('JS')),
                title: Text('João Santos'),
                subtitle: Text('(11) 88888-8888'),
                trailing: Icon(Icons.edit),
              ),
              ListTile(
                leading: CircleAvatar(child: Text('AL')),
                title: Text('Ana Lima'),
                subtitle: Text('(11) 77777-7777'),
                trailing: Icon(Icons.edit),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Novo Cliente'),
          ),
        ],
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Relatórios'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Relatório Mensal'),
                subtitle: const Text('Agendamentos e receita'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerando relatório mensal...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Relatório de Clientes'),
                subtitle: const Text('Lista completa de clientes'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerando relatório de clientes...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Relatório Financeiro'),
                subtitle: const Text('Receitas e despesas'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerando relatório financeiro...')),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}