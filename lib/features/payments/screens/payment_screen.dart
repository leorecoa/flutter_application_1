import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../../pix/services/pix_service.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/pix_payment_dialog.dart';
import '../widgets/stripe_payment_dialog.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _pixService = PixService();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _selectedMethod;

  final double _planPrice = 90.00;
  final String _planDescription = 'Plano Premium - Corte + Barba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plano
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
            PaymentMethodCard(
              icon: Icons.pix,
              title: 'PIX',
              subtitle: 'Pagamento instantâneo',
              isSelected: _selectedMethod == 'pix',
              onTap: () => _selectPaymentMethod('pix'),
            ),
            
            const SizedBox(height: 12),
            
            // Cartão de Crédito (Stripe)
            PaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Cartão de Crédito',
              subtitle: 'Visa, Mastercard, Elo',
              isSelected: _selectedMethod == 'stripe',
              onTap: () => _selectPaymentMethod('stripe'),
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
              'Atendimento personalizado',
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
                'Pagamento Seguro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Seus dados estão protegidos com criptografia SSL. '
            'Utilizamos Stripe para cartões e sistema PIX oficial do Banco Central.',
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

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedMethod = method;
    });
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
      final pixData = await _pixService.generatePixPayment(
        amount: _planPrice,
        description: _planDescription,
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
      final stripeData = await _pixService.generateStripePayment(
        amount: _planPrice,
        description: _planDescription,
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
          'Você já pode agendar seu atendimento.',
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