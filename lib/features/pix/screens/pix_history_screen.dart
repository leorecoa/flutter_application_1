import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';

class PixHistoryScreen extends StatefulWidget {
  const PixHistoryScreen({super.key});

  @override
  State<PixHistoryScreen> createState() => _PixHistoryScreenState();
}

class _PixHistoryScreenState extends State<PixHistoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _loadTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      // Simular carregamento de transações
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _transactions = [
          {
            'id': 'PIX1689524789123',
            'valor': 99.90,
            'status': 'PAGO',
            'data_criacao': '2025-07-01',
            'data_pagamento': '2025-07-01',
            'descricao': 'Mensalidade Julho 2025',
            'cliente': 'Clínica Bella Vista',
          },
          {
            'id': 'PIX1689438965478',
            'valor': 149.90,
            'status': 'PAGO',
            'data_criacao': '2025-06-15',
            'data_pagamento': '2025-06-15',
            'descricao': 'Mensalidade Junho 2025',
            'cliente': 'Barbearia Vintage',
          },
          {
            'id': 'PIX1689352478965',
            'valor': 99.90,
            'status': 'PENDENTE',
            'data_criacao': '2025-07-10',
            'data_pagamento': null,
            'descricao': 'Mensalidade Julho 2025',
            'cliente': 'Salão Beauty Plus',
          },
          {
            'id': 'PIX1689265987412',
            'valor': 199.90,
            'status': 'CANCELADO',
            'data_criacao': '2025-06-28',
            'data_pagamento': null,
            'descricao': 'Plano Premium - Junho 2025',
            'cliente': 'Studio Nail Art',
          },
          {
            'id': 'PIX1689179654789',
            'valor': 149.90,
            'status': 'PAGO',
            'data_criacao': '2025-05-15',
            'data_pagamento': '2025-05-15',
            'descricao': 'Mensalidade Maio 2025',
            'cliente': 'Barbearia Vintage',
          },
        ];
      });

      _animationController.forward();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar histórico: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Histórico de PIX',
      currentPath: AppRoutes.pixHistory,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico de Pagamentos',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                'Visualize todos os pagamentos recebidos e pendentes',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),

        // Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: AppTextStyles.labelMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    value: 'TODOS',
                    items: const [
                      DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                      DropdownMenuItem(value: 'PAGO', child: Text('Pagos')),
                      DropdownMenuItem(
                          value: 'PENDENTE', child: Text('Pendentes')),
                      DropdownMenuItem(
                          value: 'CANCELADO', child: Text('Cancelados')),
                    ],
                    onChanged: (value) {
                      // Implementar filtro
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _loadTransactions,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de transações
        Expanded(
          child: _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma transação encontrada',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Gerar PIX',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.generatePix),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return _buildTransactionCard(transaction, index);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    final status = transaction['status'];
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'PAGO':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'PENDENTE':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'CANCELADO':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.grey500;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Implementar visualização detalhada
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction['cliente'],
                        style: AppTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  transaction['descricao'],
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currencyFormat.format(transaction['valor']),
                      style: AppTextStyles.price.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Criado em: ${_formatDate(transaction['data_criacao'])}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                if (transaction['data_pagamento'] != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Pago em: ${_formatDate(transaction['data_pagamento'])}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
