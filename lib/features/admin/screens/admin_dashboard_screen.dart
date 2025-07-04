import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/trinks_theme.dart';
import '../../../shared/models/dashboard_stats.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/dashboard_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard',
      currentRoute: '/admin',
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    const stats = DashboardStats(
      todayAppointments: 12,
      activeClients: 156,
      todayRevenue: 850.00,
      pendingPayments: 3,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatsGrid(context, stats),
          const SizedBox(height: 32),
          _buildQuickActions(context),
          const SizedBox(height: 32),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TrinksTheme.navyBlue, TrinksTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo ao AgendaFácil!',
                  style: TextStyle(
                    color: TrinksTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie sua barbearia de forma eficiente',
                  style: TextStyle(
                    color: TrinksTheme.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.content_cut,
            color: TrinksTheme.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        DashboardCard(
          title: 'Agendamentos Hoje',
          value: stats.todayAppointments.toString(),
          icon: Icons.calendar_today,
          iconColor: TrinksTheme.lightBlue,
          subtitle: '+2 desde ontem',
          onTap: () => context.go('/admin/appointments'),
        ),
        DashboardCard(
          title: 'Clientes Ativos',
          value: stats.activeClients.toString(),
          icon: Icons.people,
          iconColor: TrinksTheme.success,
          subtitle: '+8 este mês',
          onTap: () => context.go('/admin/clients'),
        ),
        DashboardCard(
          title: 'Receita Hoje',
          value: 'R\$ ${stats.todayRevenue.toStringAsFixed(0)}',
          icon: Icons.attach_money,
          iconColor: TrinksTheme.purple,
          subtitle: 'Meta: R\$ 1.000',
          onTap: () => context.go('/admin/financial'),
        ),
        DashboardCard(
          title: 'Pagamentos Pendentes',
          value: stats.pendingPayments.toString(),
          icon: Icons.pending_actions,
          iconColor: TrinksTheme.warning,
          subtitle: 'Requer atenção',
          onTap: () => context.go('/admin/financial'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Novo Agendamento',
                Icons.add_circle_outline,
                TrinksTheme.navyBlue,
                () => context.go('/admin/appointments/new'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Cadastrar Cliente',
                Icons.person_add_outlined,
                TrinksTheme.success,
                () => context.go('/admin/clients/new'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Relatórios',
                Icons.analytics_outlined,
                TrinksTheme.purple,
                () => context.go('/admin/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: TrinksTheme.cardDecoration,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: TrinksTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atividade Recente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
              'João Silva agendou corte para hoje às 14:00', '2 min atrás'),
          _buildActivityItem('Pagamento de R\$ 45,00 recebido de Carlos Santos',
              '15 min atrás'),
          _buildActivityItem(
              'Maria Oliveira cancelou agendamento', '1 hora atrás'),
          _buildActivityItem(
              'Novo cliente cadastrado: Pedro Costa', '2 horas atrás'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: TrinksTheme.lightBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: TrinksTheme.darkGray),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: TrinksTheme.darkGray.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
