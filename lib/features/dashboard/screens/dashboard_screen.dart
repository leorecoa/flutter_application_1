import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/primary_button.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  
  // Mock data
  final Map<String, dynamic> _dashboardData = {
    'totalClientes': 25,
    'clientesPagos': 20,
    'clientesPendentes': 3,
    'clientesVencidos': 2,
    'receitaMensal': 1998.00,
    'proximoVencimento': '2025-07-15',
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Simular carregamento
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.h4),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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
                        'Gerencie suas cobranças e clientes de forma simples',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 24),
                  PrimaryButton(
                    text: 'Gerar PIX',
                    icon: Icons.qr_code,
                    onPressed: () => context.go(AppRoutes.generatePix),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            
            // Cards de estatísticas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 1.2 : 1.1,
              children: [
                DashboardCard(
                  title: 'Total de Clientes',
                  value: _isLoading ? '...' : '${_dashboardData['totalClientes']}',
                  subtitle: 'Empresas cadastradas',
                  icon: Icons.business,
                  isLoading: _isLoading,
                ),
                DashboardCard(
                  title: 'Pagamentos em Dia',
                  value: _isLoading ? '...' : '${_dashboardData['clientesPagos']}',
                  subtitle: 'Clientes ativos',
                  icon: Icons.check_circle,
                  iconColor: AppColors.success,
                  isLoading: _isLoading,
                ),
                DashboardCard(
                  title: 'Pendentes',
                  value: _isLoading ? '...' : '${_dashboardData['clientesPendentes']}',
                  subtitle: 'Aguardando pagamento',
                  icon: Icons.schedule,
                  iconColor: AppColors.warning,
                  isLoading: _isLoading,
                ),
                DashboardCard(
                  title: 'Em Atraso',
                  value: _isLoading ? '...' : '${_dashboardData['clientesVencidos']}',
                  subtitle: 'Requer atenção',
                  icon: Icons.error,
                  iconColor: AppColors.error,
                  isLoading: _isLoading,
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Receita mensal
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Receita Mensal',
                          style: AppTextStyles.h5,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      Container(
                        width: 120,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Text(
                        'R\$ ${_dashboardData['receitaMensal'].toStringAsFixed(2)}',
                        style: AppTextStyles.price,
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
            const SizedBox(height: 24),
            
            // Ações rápidas
            Text(
              'Ações Rápidas',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 16),
            
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Gerar QR Code PIX',
                      icon: Icons.qr_code,
                      onPressed: () => context.go(AppRoutes.generatePix),
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
    );
  }
}