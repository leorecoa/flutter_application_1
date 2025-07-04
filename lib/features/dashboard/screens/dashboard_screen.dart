import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/primary_button.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data
  final Map<String, dynamic> _dashboardData = {
    'totalClientes': 25,
    'clientesPagos': 20,
    'clientesPendentes': 3,
    'clientesVencidos': 2,
    'receitaMensal': 1998.00,
    'proximoVencimento': '2025-07-15',
    'agendamentosHoje': 8,
    'agendamentosAmanha': 12,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // Simular carregamento
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return AppScaffold(
      title: 'Dashboard',
      currentPath: AppRoutes.dashboard,
      isLoading: _isLoading,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar ação de novo agendamento
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bem-vindo ao AgendeMais! 👋',
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gerencie seus agendamentos e pagamentos de forma simples',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (isDesktop || isTablet) ...[
                          const SizedBox(width: 24),
                          PrimaryButton(
                            text: 'Novo Agendamento',
                            icon: Icons.add_circle_outline,
                            isSecondary: true,
                            onPressed: () {
                              // Implementar ação de novo agendamento
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Cards de estatísticas
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isDesktop ? 1.2 : 1.1,
                      children: [
                        DashboardCard(
                          title: 'Total de Clientes',
                          value: '${_dashboardData['totalClientes']}',
                          subtitle: 'Empresas cadastradas',
                          icon: Icons.business,
                          isLoading: _isLoading,
                        ),
                        DashboardCard(
                          title: 'Pagamentos em Dia',
                          value: '${_dashboardData['clientesPagos']}',
                          subtitle: 'Clientes ativos',
                          icon: Icons.check_circle,
                          iconColor: AppColors.success,
                          isLoading: _isLoading,
                          animationDelay: 100,
                        ),
                        DashboardCard(
                          title: 'Pendentes',
                          value: '${_dashboardData['clientesPendentes']}',
                          subtitle: 'Aguardando pagamento',
                          icon: Icons.schedule,
                          iconColor: AppColors.warning,
                          isLoading: _isLoading,
                          animationDelay: 200,
                        ),
                        DashboardCard(
                          title: 'Em Atraso',
                          value: '${_dashboardData['clientesVencidos']}',
                          subtitle: 'Requer atenção',
                          icon: Icons.error,
                          iconColor: AppColors.error,
                          isLoading: _isLoading,
                          animationDelay: 300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Receita mensal
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: AppColors.white,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: AppColors.success,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Receita Mensal',
                                  style: AppTextStyles.h5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'R\$ ${_dashboardData['receitaMensal'].toStringAsFixed(2)}',
                              style: AppTextStyles.statValue.copyWith(
                                color: AppColors.success,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Valor total arrecadado este mês',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Agendamentos
                    Text(
                      'Agendamentos',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildAgendamentosCard(
                            'Hoje',
                            _dashboardData['agendamentosHoje'],
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAgendamentosCard(
                            'Amanhã',
                            _dashboardData['agendamentosAmanha'],
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Ações rápidas
                    Text(
                      'Ações Rápidas',
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: 16),

                    if (isDesktop || isTablet)
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              text: 'Gerar QR Code PIX',
                              icon: Icons.qr_code,
                              onPressed: () =>
                                  context.go(AppRoutes.generatePix),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Histórico de Cobranças',
                              icon: Icons.history,
                              isOutlined: true,
                              onPressed: () => context.go(AppRoutes.pixHistory),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          PrimaryButton(
                            text: 'Gerar QR Code PIX',
                            icon: Icons.qr_code,
                            width: double.infinity,
                            onPressed: () => context.go(AppRoutes.generatePix),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: 'Histórico de Cobranças',
                            icon: Icons.history,
                            width: double.infinity,
                            isOutlined: true,
                            onPressed: () => context.go(AppRoutes.pixHistory),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAgendamentosCard(String title, int count, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: AppTextStyles.statValue,
            ),
            const SizedBox(height: 4),
            Text(
              'Agendamentos',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
