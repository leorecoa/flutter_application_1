import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';

class PagamentosTable extends StatelessWidget {
  final List<Payment> payments;
  final Function(Payment) onEdit;
  final Function(String) onCancel;
  final Function(Payment) onEmitirRecibo;
  final bool isLoading;

  const PagamentosTable({
    super.key,
    required this.payments,
    required this.onEdit,
    required this.onCancel,
    required this.onEmitirRecibo,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (payments.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          _buildTableHeader(),
          ...payments.map((payment) => _buildTableRow(payment)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TrinksTheme.lightGray,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Serviço', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Valor', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Forma Pagamento', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Data', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Ações', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildTableRow(Payment payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TrinksTheme.lightGray)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.clienteNome,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  payment.barbeiroNome,
                  style: TextStyle(
                    fontSize: 12,
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(payment.servicoNome)),
          Expanded(
            flex: 1,
            child: Text(
              'R\$ ${payment.valor.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 2, child: _buildFormaPagamentoChip(payment.formaPagamento)),
          Expanded(flex: 1, child: _buildStatusChip(payment.status)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(payment.data)),
                Text(
                  DateFormat('HH:mm').format(payment.data),
                  style: TextStyle(
                    fontSize: 12,
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _buildActions(payment)),
        ],
      ),
    );
  }

  Widget _buildFormaPagamentoChip(FormaPagamento forma) {
    IconData icon;
    Color color;
    String text;
    
    switch (forma) {
      case FormaPagamento.pix:
        icon = Icons.pix_outlined;
        color = TrinksTheme.lightBlue;
        text = 'PIX';
        break;
      case FormaPagamento.dinheiro:
        icon = Icons.attach_money;
        color = TrinksTheme.success;
        text = 'Dinheiro';
        break;
      case FormaPagamento.cartao:
        icon = Icons.credit_card;
        color = TrinksTheme.purple;
        text = 'Cartão';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
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
    );
  }

  Widget _buildStatusChip(StatusPagamento status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case StatusPagamento.pago:
        color = TrinksTheme.success;
        text = 'Pago';
        icon = Icons.check_circle_outline;
        break;
      case StatusPagamento.pendente:
        color = TrinksTheme.warning;
        text = 'Pendente';
        icon = Icons.schedule_outlined;
        break;
      case StatusPagamento.cancelado:
        color = TrinksTheme.error;
        text = 'Cancelado';
        icon = Icons.cancel_outlined;
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
          Icon(icon, size: 12, color: color),
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

  Widget _buildActions(Payment payment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (payment.status != StatusPagamento.cancelado) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => onEdit(payment),
            tooltip: 'Editar',
          ),
          if (payment.status == StatusPagamento.pago)
            IconButton(
              icon: const Icon(Icons.receipt_outlined, size: 18, color: TrinksTheme.lightBlue),
              onPressed: () => onEmitirRecibo(payment),
              tooltip: 'Emitir Recibo',
            ),
          if (payment.status != StatusPagamento.pago)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, size: 18, color: TrinksTheme.error),
              onPressed: () => onCancel(payment.id),
              tooltip: 'Cancelar',
            ),
        ],
      ],
    );
  }
}