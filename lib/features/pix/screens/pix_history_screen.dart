import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PixHistoryScreen extends StatefulWidget {
  const PixHistoryScreen({super.key});

  @override
  State<PixHistoryScreen> createState() => _PixHistoryScreenState();
}

class _PixHistoryScreenState extends State<PixHistoryScreen> {
  bool _isLoading = true;
  String _selectedFilter = 'TODOS';
  
  final List<Map<String, dynamic>> _mockHistory = [
    {
      'empresa_id': 'clinica-abc-123',
      'valor': 99.90,
      'status': 'PAGO',
      'vencimento': '2025-07-01',
      'descricao': 'Mensalidade Julho 2025',
      'data_pagamento': '2025-06-28',
    },
    {
      'empresa_id': 'barbearia-xyz-456',
      'valor': 79.90,
      'status': 'PENDENTE',
      'vencimento': '2025-07-15',
      'descricao': 'Mensalidade Julho 2025',
      'data_pagamento': null,
    },
    {
      'empresa_id': 'salao-beauty-789',
      'valor': 129.90,
      'status': 'VENCIDO',
      'vencimento': '2025-06-30',
      'descricao': 'Mensalidade Junho 2025',
      'data_pagamento': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'TODOS') return _mockHistory;
    return _mockHistory.where((item) => item['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAGO':
        return AppColors.success;
      case 'PENDENTE':
        return AppColors.warning;
      case 'VENCIDO':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PAGO':
        return 'Pago';
      case 'PENDENTE':
        return 'Pendente';
      case 'VENCIDO':
        return 'Vencido';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Cobranças', style: AppTextStyles.h4),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Filtrar por:', style: AppTextStyles.labelMedium),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['TODOS', 'PAGO', 'PENDENTE', 'VENCIDO']
                          .map((filter) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                  selectedColor: AppColors.primary.withOpacity(0.2),
                                  checkmarkColor: AppColors.primary,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma cobrança encontrada',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = _filteredHistory[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['status'] == 'PAGO'
                                      ? Icons.check_circle
                                      : item['status'] == 'PENDENTE'
                                          ? Icons.schedule
                                          : Icons.error,
                                  color: _getStatusColor(item['status']),
                                ),
                              ),
                              title: Text(
                                item['empresa_id'],
                                style: AppTextStyles.labelLarge,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item['descricao'],
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vencimento: ${item['vencimento']}',
                                    style: AppTextStyles.caption,
                                  ),
                                  if (item['data_pagamento'] != null)
                                    Text(
                                      'Pago em: ${item['data_pagamento']}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${item['valor'].toStringAsFixed(2)}',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(item['status']),
                                      style: AppTextStyles.caption.copyWith(
                                        color: _getStatusColor(item['status']),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}