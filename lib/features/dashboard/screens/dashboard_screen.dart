import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service_local.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/user_model.dart';

/// Tela principal do dashboard
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AGENDEMAIS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go('/notifications'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/settings');
                  break;
                case 'logout':
                  _showLogoutDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Recarregar dados do dashboard
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com boas-vindas
              _buildWelcomeHeader(user),
              const SizedBox(height: 24),

              // Cards de estatísticas
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Ações rápidas
              _buildQuickActionsSection(context),
              const SizedBox(height: 24),

              // Agendamentos recentes
              _buildRecentAppointmentsSection(),
              const SizedBox(height: 24),

              // Seção de relatórios
              _buildReportsSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Header com boas-vindas
  Widget _buildWelcomeHeader(User? user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user?.name ?? 'Usuário'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aqui está um resumo do seu negócio hoje',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de estatísticas
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas do Dia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: const [
            DashboardStatsCard(
              title: 'Agendamentos',
              value: '12',
              subtitle: 'Hoje',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            DashboardStatsCard(
              title: 'Clientes',
              value: '45',
              subtitle: 'Total',
              icon: Icons.people,
              color: Colors.green,
            ),
            DashboardStatsCard(
              title: 'Receita',
              value: 'R\$ 1.250',
              subtitle: 'Este mês',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
            DashboardStatsCard(
              title: 'Serviços',
              value: '8',
              subtitle: 'Ativos',
              icon: Icons.work,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  /// Seção de ações rápidas
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        QuickActionsCard(
          actions: [
            QuickAction(
              title: 'Novo Agendamento',
              icon: Icons.add_circle,
              color: Colors.blue,
              onTap: () => context.go('/appointments/create'),
            ),
            QuickAction(
              title: 'Novo Cliente',
              icon: Icons.person_add,
              color: Colors.green,
              onTap: () => context.go('/clients/create'),
            ),
            QuickAction(
              title: 'Relatórios',
              icon: Icons.analytics,
              color: Colors.orange,
              onTap: () => context.go('/reports'),
            ),
            QuickAction(
              title: 'Configurações',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  /// Seção de agendamentos recentes
  Widget _buildRecentAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agendamentos Recentes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        RecentAppointmentsCard(
          appointments: [
            Appointment(
              id: '1',
              clientName: 'João Silva',
              serviceName: 'Corte Masculino',
              date: DateTime.now().add(const Duration(hours: 2)),
              startTime: '14:00',
              status: 'confirmed',
            ),
            Appointment(
              id: '2',
              clientName: 'Maria Santos',
              serviceName: 'Manicure',
              date: DateTime.now().add(const Duration(hours: 4)),
              startTime: '16:00',
              status: 'pending',
            ),
          ],
        ),
      ],
    );
  }

  /// Seção de relatórios
  Widget _buildReportsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relatórios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.blue),
                  title: const Text('Relatório Mensal'),
                  subtitle: const Text('Agendamentos e receita do mês'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reports/monthly'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.green),
                  title: const Text('Relatório de Clientes'),
                  subtitle: const Text('Análise de clientes'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reports/clients'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.orange),
                  title: const Text('Relatório Financeiro'),
                  subtitle: const Text('Receitas e despesas'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/reports/financial'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Barra de navegação inferior
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/appointments');
            break;
          case 2:
            context.go('/clients');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Agendamentos',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configurações',
        ),
      ],
    );
  }

  /// Dialog de confirmação de logout
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

/// Widget para card de estatísticas
class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para card de ações rápidas
class QuickActionsCard extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsCard({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: actions
              .map(
                (action) => ListTile(
                  leading: Icon(action.icon, color: action.color),
                  title: Text(action.title),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: action.onTap,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Modelo para ação rápida
class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Widget para card de agendamentos recentes
class RecentAppointmentsCard extends StatelessWidget {
  final List<Appointment> appointments;

  const RecentAppointmentsCard({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próximos Agendamentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...appointments.map(
              (appointment) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(appointment.status),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                title: Text(appointment.clientName),
                subtitle: Text(
                  '${appointment.serviceName} - ${appointment.startTime}',
                ),
                trailing: Chip(
                  label: Text(
                    _getStatusText(appointment.status),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(
                    appointment.status,
                  ).withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }
}

/// Modelo de agendamento (simplificado)
class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final DateTime date;
  final String startTime;
  final String status;

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.date,
    required this.startTime,
    required this.status,
  });
}
