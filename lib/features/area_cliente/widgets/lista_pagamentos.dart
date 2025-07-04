import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../../payments/models/payment_model.dart';
import '../utils/pdf_generator.dart';

class ListaPagamentos extends StatelessWidget {
  final List<Payment> pagamentos;
  final bool isLoading;

  const ListaPagamentos({
    required this.pagamentos,
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pagamentos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pagamentos.length,
      itemBuilder: (context, index) {
        final pagamento = pagamentos[index];
        return _buildPagamentoCard(context, pagamento);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: TrinksTheme.darkGray.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pagamento encontrado',
            style: TextStyle(
              fontSize: 18,
              color: TrinksTheme.darkGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagamentoCard(BuildContext context, Payment pagamento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TrinksTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getFormaPagamentoColor(pagamento.formaPagamento)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFormaPagamentoIcon(pagamento.formaPagamento),
              color: _getFormaPagamentoColor(pagamento.formaPagamento),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getFormaPagamentoEmoji(pagamento.formaPagamento),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(pagamento.data),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pagamento.servicoNome} com ${pagamento.barbeiroNome}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: TrinksTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'R\$ ${pagamento.valor.toStringAsFixed(2)} via ${_getFormaPagamentoText(pagamento.formaPagamento)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: TrinksTheme.navyBlue,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusChip(pagamento.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (pagamento.status == StatusPagamento.pago)
            IconButton(
              onPressed: () => _gerarRecibo(context, pagamento),
              icon: const Icon(Icons.receipt_outlined,
                  color: TrinksTheme.lightBlue),
              tooltip: 'Ver Recibo',
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatusPagamento status) {
    String emoji;
    String text;
    Color color;

    switch (status) {
      case StatusPagamento.pago:
        emoji = '✅';
        text = 'Pago';
        color = TrinksTheme.success;
        break;
      case StatusPagamento.pendente:
        emoji = '⏳';
        text = 'Pendente';
        color = TrinksTheme.warning;
        break;
      case StatusPagamento.cancelado:
        emoji = '❌';
        text = 'Cancelado';
        color = TrinksTheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormaPagamentoEmoji(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return '📱';
      case FormaPagamento.cartao:
        return '💳';
      case FormaPagamento.dinheiro:
        return '💰';
    }
  }

  String _getFormaPagamentoText(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return 'PIX';
      case FormaPagamento.cartao:
        return 'Cartão';
      case FormaPagamento.dinheiro:
        return 'Dinheiro';
    }
  }

  IconData _getFormaPagamentoIcon(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return Icons.pix_outlined;
      case FormaPagamento.cartao:
        return Icons.credit_card;
      case FormaPagamento.dinheiro:
        return Icons.attach_money;
    }
  }

  Color _getFormaPagamentoColor(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return TrinksTheme.lightBlue;
      case FormaPagamento.cartao:
        return TrinksTheme.purple;
      case FormaPagamento.dinheiro:
        return TrinksTheme.success;
    }
  }

  void _gerarRecibo(BuildContext context, Payment pagamento) {
    PDFGenerator.gerarRecibo(context, pagamento);
  }
}
