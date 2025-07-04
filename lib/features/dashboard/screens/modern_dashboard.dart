import 'package:flutter/material.dart';

import '../../../core/theme/trinks_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/modern_sidebar.dart';

class ModernDashboard extends StatelessWidget {
  const ModernDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrinksTheme.lightGray,
      body: Row(
        children: [
          const ModernSidebar(currentRoute: '/dashboard'),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TrinksTheme.white,
                    boxShadow: [
                      BoxShadow(
                        color: TrinksTheme.darkGray.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: TrinksTheme.darkGray,
                            ),
                          ),
                          Text(
                            'Visão geral do seu negócio',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: TrinksTheme.navyBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: TrinksTheme.navyBlue),
                            SizedBox(width: 8),
                            Text(
                              'Hoje - 15 Dezembro',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: TrinksTheme.navyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // KPIs Row
                        const Row(
                          children: [
                            Expanded(
                              child: KpiCard(
                                title: 'Agendamentos Hoje',
                                value: '12',
                                icon: Icons.calendar_today,
                                color: TrinksTheme.navyBlue,
                                percentage: 15.2,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: KpiCard(
                                title: 'Faturamento',
                                value: 'R\$ 2.450',
                                icon: Icons.attach_money,
                                color: TrinksTheme.success,
                                percentage: 8.7,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: KpiCard(
                                title: 'Cancelamentos',
                                value: '2',
                                icon: Icons.cancel_outlined,
                                color: TrinksTheme.error,
                                percentage: -5.1,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: KpiCard(
                                title: 'Taxa Ocupação',
                                value: '85%',
                                icon: Icons.trending_up,
                                color: TrinksTheme.purple,
                                percentage: 12.3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Charts Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Próximos Agendamentos
                            Expanded(
                              flex: 2,
                              child: ModernCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Próximos Agendamentos',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: TrinksTheme.darkGray,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text('Ver todos'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...List.generate(
                                        4,
                                        (index) => _buildAppointmentItem(
                                              '${9 + index}:00',
                                              'Maria Silva',
                                              'Corte + Escova',
                                              index == 0
                                                  ? 'Em andamento'
                                                  : 'Agendado',
                                              index == 0
                                                  ? TrinksTheme.warning
                                                  : TrinksTheme.success,
                                            )),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Serviços Populares
                            Expanded(
                              child: ModernCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Serviços Populares',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: TrinksTheme.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildServiceItem('Corte Masculino', 45,
                                        TrinksTheme.navyBlue),
                                    _buildServiceItem('Corte + Escova', 32,
                                        TrinksTheme.purple),
                                    _buildServiceItem(
                                        'Barba', 28, TrinksTheme.success),
                                    _buildServiceItem(
                                        'Manicure', 15, TrinksTheme.warning),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String time, String client, String service,
      String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TrinksTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TrinksTheme.darkGray,
                  ),
                ),
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TrinksTheme.darkGray,
              ),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
