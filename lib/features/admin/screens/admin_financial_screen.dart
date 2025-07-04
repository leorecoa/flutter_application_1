import 'package:flutter/material.dart';

import '../../../core/theme/trinks_theme.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../shared/widgets/dashboard_card.dart';

class AdminFinancialScreen extends StatelessWidget {
  const AdminFinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Financeiro',
      currentRoute: '/admin/financial',
      child: _buildFinancialContent(),
    );
  }

  Widget _buildFinancialContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialStats(),
          const SizedBox(height: 32),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildFinancialStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: const [
        DashboardCard(
          title: 'Receita Hoje',
          value: 'R\$ 850',
          icon: Icons.trending_up,
          iconColor: TrinksTheme.success,
          subtitle: '+12% vs ontem',
        ),
        DashboardCard(
          title: 'Receita Mês',
          value: 'R\$ 15.420',
          icon: Icons.calendar_month,
          iconColor: TrinksTheme.lightBlue,
          subtitle: 'Meta: R\$ 20.000',
        ),
        DashboardCard(
          title: 'Pendentes',
          value: 'R\$ 180',
          icon: Icons.pending_actions,
          iconColor: TrinksTheme.warning,
          subtitle: '3 pagamentos',
        ),
        DashboardCard(
          title: 'Ticket Médio',
          value: 'R\$ 42',
          icon: Icons.receipt_long,
          iconColor: TrinksTheme.purple,
          subtitle: '+R\$ 3 vs mês anterior',
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transações Recentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TrinksTheme.darkGray,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransactionItem(
              'João Silva', 'Corte + Barba', 'R\$ 55,00', 'Pago', true),
          _buildTransactionItem(
              'Carlos Santos', 'Corte', 'R\$ 35,00', 'Pendente', false),
          _buildTransactionItem(
              'Pedro Costa', 'Barba', 'R\$ 25,00', 'Pago', true),
          _buildTransactionItem('Maria Oliveira', 'Corte + Sobrancelha',
              'R\$ 50,00', 'Pago', true),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String client, String service, String amount,
      String status, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: TrinksTheme.lightPurple,
            child: Text(client[0],
                style: const TextStyle(color: TrinksTheme.navyBlue)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TrinksTheme.darkGray,
                  ),
                ),
                Text(
                  service,
                  style: TextStyle(
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: TrinksTheme.darkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? TrinksTheme.success : TrinksTheme.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: TrinksTheme.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
