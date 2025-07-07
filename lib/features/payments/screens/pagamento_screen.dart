import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../services/pagamento_service.dart';
import '../widgets/pix_payment_dialog.dart';

class PagamentoScreen extends StatefulWidget {
  const PagamentoScreen({super.key});

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  final _pagamentoService = PagamentoService();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _selectedMethod;

  final double _planPrice = 90.00;
  final String _planDescription = 'Plano Premium - Corte + Barba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plano Premium
            _buildPlanCard(),
            
            const SizedBox(height: 24),
            
            // Métodos de Pagamento
            const Text(
              'Escolha a forma de pagamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // PIX
            _buildPaymentMethodCard(
              icon: Icons.pix,
              title: 'PIX',
              subtitle: 'Banco PAM - Pagamento instantâneo',
              method: 'pix',
            ),
            
            const SizedBox(height: 12),
            
            // Cartão de Crédito (Stripe)
            _buildPaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Cartão de Crédito',
              subtitle: 'Visa, Mastercard, Elo via Stripe',
              method: 'stripe',
            ),
            
            const SizedBox(height: 32),
            
            // Botão Pagar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _selectedMethod == null 
                    ? null 
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pagar R\$ ${_planPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informações de Segurança
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFF667eea),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plano Premium',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Corte + Barba Completa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${_planPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const Text(
                      'à vista',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Benefícios
            const Text(
              'Inclui:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            ...[
              'Corte de cabelo profissional',
              'Barba completa com máquina e navalha',
              'Finalização com produtos premium',
              'Agendamento prioritário',
            ].map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(benefit),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String method,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF667eea) 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF667eea) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF667eea),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Pagamento 100% Seguro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PIX: Chave CPF 05359566493 - Leandro Jesse da Silva (Banco PAM)\n'
            'Cartão: Processamento seguro via Stripe com criptografia SSL',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedMethod == 'pix') {
        await _processPixPayment();
      } else if (_selectedMethod == 'stripe') {
        await _processStripePayment();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processPixPayment() async {
    try {
      final pixData = await _pagamentoService.criarPagamentoPix(
        valor: _planPrice,
        descricao: _planDescription,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PixPaymentDialog(
            pixData: pixData,
            onPaymentCompleted: () {
              Navigator.of(context).pop(); // Fechar dialog
              _showPaymentSuccess();
            },
          ),
        );
      }
    } catch (e) {
      throw Exception('Erro ao gerar PIX: $e');
    }
  }

  Future<void> _processStripePayment() async {
    try {
      final stripeData = await _pagamentoService.criarPagamentoStripe(
        valor: _planPrice,
        descricao: _planDescription,
      );

      final checkoutUrl = stripeData['checkoutUrl'];
      if (checkoutUrl != null) {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Não foi possível abrir o checkout');
        }
      } else {
        throw Exception('URL de checkout não recebida');
      }
    } catch (e) {
      throw Exception('Erro ao processar pagamento: $e');
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Pagamento Confirmado!'),
        content: const Text(
          'Seu pagamento foi processado com sucesso. '
          'Você já pode agendar seu atendimento premium.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(); // Voltar para tela anterior
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}