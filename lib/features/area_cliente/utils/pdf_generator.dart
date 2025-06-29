import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../../payments/models/payment_model.dart';

class PDFGenerator {
  static void gerarRecibo(BuildContext context, Payment pagamento) {
    showDialog(
      context: context,
      builder: (context) => ReciboDialog(pagamento: pagamento),
    );
  }
}

class ReciboDialog extends StatelessWidget {
  final Payment pagamento;

  const ReciboDialog({super.key, required this.pagamento});

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
          _buildClienteInfo(),
          const Divider(height: 32),
          _buildServicoInfo(),
          const Divider(height: 32),
          _buildPagamentoInfo(),
          const Divider(height: 32),
          _buildTotal(),
          const SizedBox(height: 16),
          _buildAutenticacao(),
        ],
      ),
    );
  }

  Widget _buildBarbeariHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              child: const Icon(Icons.content_cut, color: TrinksTheme.white, size: 24),
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
          'CNPJ: 12.345.678/0001-90',
          style: TextStyle(
            fontSize: 12,
            color: TrinksTheme.darkGray.withValues(alpha: 0.6),
          ),
        ),
        Text(
          'Rua das Flores, 123 - Centro - São Paulo/SP',
          style: TextStyle(
            fontSize: 12,
            color: TrinksTheme.darkGray.withValues(alpha: 0.6),
          ),
        ),
        Text(
          'Tel: (11) 99999-9999',
          style: TextStyle(
            fontSize: 12,
            color: TrinksTheme.darkGray.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildClienteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DADOS DO CLIENTE',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: TrinksTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Nome:', pagamento.clienteNome),
        _buildInfoRow('Data do Atendimento:', DateFormat('dd/MM/yyyy HH:mm').format(pagamento.data)),
      ],
    );
  }

  Widget _buildServicoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SERVIÇO PRESTADO',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: TrinksTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Serviço:', pagamento.servicoNome),
        _buildInfoRow('Profissional:', pagamento.barbeiroNome),
      ],
    );
  }

  Widget _buildPagamentoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INFORMAÇÕES DE PAGAMENTO',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: TrinksTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Forma de Pagamento:', _getFormaPagamentoText(pagamento.formaPagamento)),
        _buildInfoRow('Data do Pagamento:', DateFormat('dd/MM/yyyy HH:mm').format(pagamento.data)),
        if (pagamento.chavePix != null)
          _buildInfoRow('Chave PIX:', pagamento.chavePix!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: TrinksTheme.darkGray,
                fontSize: 12,
              ),
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
            'VALOR TOTAL PAGO:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.darkGray,
            ),
          ),
          Text(
            'R\$ ${pagamento.valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutenticacao() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TrinksTheme.lightPurple,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          const Text(
            'CÓDIGO DE AUTENTICAÇÃO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.navyBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AF-${pagamento.id.toUpperCase()}-${DateTime.now().year}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _compartilharWhatsApp(),
          icon: const Icon(Icons.share, color: TrinksTheme.success),
          label: const Text('Compartilhar', style: TextStyle(color: TrinksTheme.success)),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _baixarPDF(),
          icon: const Icon(Icons.download),
          label: const Text('Baixar PDF'),
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
    // ignore: avoid_print
    print('Compartilhar recibo via WhatsApp');
  }

  void _baixarPDF() {
    // ignore: avoid_print
    print('Baixar recibo em PDF');
  }
}