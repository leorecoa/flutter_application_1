import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';

class ReciboModal extends StatelessWidget {
  final Payment payment;

  const ReciboModal({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildRecibo(),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recibo de Pagamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildRecibo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: TrinksTheme.darkGray.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBarbeariHeader(),
          const Divider(height: 32),
          _buildReciboInfo(),
          const Divider(height: 32),
          _buildTotal(),
          if (payment.observacoes != null) ...[
            const SizedBox(height: 16),
            _buildObservacoes(),
          ],
        ],
      ),
    );
  }

  Widget _buildBarbeariHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TrinksTheme.navyBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.content_cut,
                  color: TrinksTheme.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'AgendaFácil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: TrinksTheme.navyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Barbearia do João',
          style: TextStyle(
            fontSize: 16,
            color: TrinksTheme.darkGray.withValues(alpha: 0.8),
          ),
        ),
        Text(
          'Rua das Flores, 123 - Centro',
          style: TextStyle(
            fontSize: 14,
            color: TrinksTheme.darkGray.withValues(alpha: 0.6),
          ),
        ),
        Text(
          '(11) 99999-9999',
          style: TextStyle(
            fontSize: 14,
            color: TrinksTheme.darkGray.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildReciboInfo() {
    return Column(
      children: [
        _buildInfoRow('Recibo Nº:', payment.id),
        _buildInfoRow(
            'Data:', DateFormat('dd/MM/yyyy HH:mm').format(payment.data)),
        _buildInfoRow('Cliente:', payment.clienteNome),
        _buildInfoRow('Serviço:', payment.servicoNome),
        _buildInfoRow('Profissional:', payment.barbeiroNome),
        _buildInfoRow('Forma de Pagamento:',
            _getFormaPagamentoText(payment.formaPagamento)),
        if (payment.chavePix != null)
          _buildInfoRow('Chave PIX:', payment.chavePix!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: TrinksTheme.darkGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: TrinksTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TrinksTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL PAGO:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.darkGray,
            ),
          ),
          Text(
            'R\$ ${payment.valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observações:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          payment.observacoes!,
          style: TextStyle(
            color: TrinksTheme.darkGray.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _compartilharWhatsApp(),
          icon: const Icon(Icons.share, color: TrinksTheme.success),
          label: const Text('WhatsApp',
              style: TextStyle(color: TrinksTheme.success)),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: () => _enviarEmail(),
          icon: const Icon(Icons.email_outlined),
          label: const Text('E-mail'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _imprimirPDF(),
          icon: const Icon(Icons.print),
          label: const Text('Imprimir PDF'),
        ),
      ],
    );
  }

  String _getFormaPagamentoText(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return 'PIX';
      case FormaPagamento.dinheiro:
        return 'Dinheiro';
      case FormaPagamento.cartao:
        return 'Cartão';
    }
  }

  void _compartilharWhatsApp() {
    // Implementar compartilhamento via WhatsApp
    // ignore: avoid_print
    print('Compartilhar via WhatsApp');
  }

  void _enviarEmail() {
    // Implementar envio por e-mail
    // ignore: avoid_print
    print('Enviar por e-mail');
  }

  void _imprimirPDF() {
    // Implementar impressão em PDF
    // ignore: avoid_print
    print('Imprimir PDF');
  }
}
