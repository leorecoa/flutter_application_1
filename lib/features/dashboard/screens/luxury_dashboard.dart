import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../shared/widgets/bottom_nav.dart';

class LuxuryDashboard extends StatefulWidget {
  const LuxuryDashboard({super.key});

  @override
  State<LuxuryDashboard> createState() => _LuxuryDashboardState();
}

class _LuxuryDashboardState extends State<LuxuryDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LuxuryTheme.pearl,
              Colors.white,
              LuxuryTheme.lightGold,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildLuxuryAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(),
                    const SizedBox(height: 32),
                    _buildMetricsGrid(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildRecentActivity(),
                    const SizedBox(height: 32),
                    _buildInsights(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildLuxuryAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: LuxuryTheme.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: LuxuryTheme.luxuryGradient,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.diamond,
                  color: LuxuryTheme.primaryGold,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'AgendaFácil Premium',
                  style: TextStyle(
                    color: LuxuryTheme.primaryGold,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: LuxuryTheme.primaryGold),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined,
              color: LuxuryTheme.primaryGold),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LuxuryTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bom dia, Profissional!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: LuxuryTheme.deepBlue,
                      ),
                    ),
                    Text(
                      'Hoje você tem 8 agendamentos confirmados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        const LuxuryCard(
          child: AnimatedCounter(
            value: 127,
            label: 'Agendamentos',
            icon: Icons.calendar_today,
            color: LuxuryTheme.primaryGold,
          ),
        ),
        LuxuryCard(
          child: AnimatedCounter(
            value: 89,
            label: 'Clientes',
            icon: Icons.people_outline,
            color: Colors.blue[600]!,
          ),
        ),
        LuxuryCard(
          child: AnimatedCounter(
            value: 15420,
            label: 'Receita (R\$)',
            icon: Icons.attach_money,
            color: Colors.green[600]!,
          ),
        ),
        LuxuryCard(
          child: AnimatedCounter(
            value: 96,
            label: 'Satisfação (%)',
            icon: Icons.star_outline,
            color: Colors.orange[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Novo Agendamento',
                Icons.add_circle_outline,
                LuxuryTheme.primaryGold,
                () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Ver Agenda',
                Icons.schedule,
                Colors.blue[600]!,
                () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Relatórios',
                Icons.analytics_outlined,
                Colors.purple[600]!,
                () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Configurações',
                Icons.settings_outlined,
                Colors.grey[600]!,
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return LuxuryCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.deepBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atividade Recente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        LuxuryCard(
          child: Column(
            children: [
              _buildActivityItem(
                'Novo agendamento confirmado',
                'Maria Silva - Corte + Escova',
                '2 min atrás',
                Icons.check_circle,
                Colors.green,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'Pagamento recebido',
                'João Santos - R\$ 85,00',
                '15 min atrás',
                Icons.payment,
                LuxuryTheme.primaryGold,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'Avaliação recebida',
                'Ana Costa - 5 estrelas',
                '1 hora atrás',
                Icons.star,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LuxuryTheme.deepBlue,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights Inteligentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        LuxuryCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.blue[400]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pico de Demanda Detectado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: LuxuryTheme.deepBlue,
                          ),
                        ),
                        Text(
                          'Sextas-feiras às 14h têm 40% mais agendamentos. Considere ajustar preços ou horários.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LuxuryTheme.lightGold.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: LuxuryTheme.darkGold,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dica: Ofereça pacotes promocionais para horários menos movimentados',
                        style: TextStyle(
                          fontSize: 13,
                          color: LuxuryTheme.darkGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
