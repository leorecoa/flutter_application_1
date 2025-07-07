import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pagamento_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _pagamentoService = PagamentoService();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Card
            _buildPlanCard(),
            
            const SizedBox(height: 24),
            
            const Text(
              'Escolha a forma de pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Methods
            _buildPaymentMethodCard(
              icon: Icons.pix,
              title: 'PIX',
              subtitle: 'Banco PAM - Pagamento instantâneo',
              method: 'pix',
            ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Cartão de Crédito',
              subtitle: 'Visa, Mastercard, Elo via Stripe',
              method: 'stripe',
            ),
            
            const Spacer(),
            
            // Pay Button
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
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pagar R\$ ${_planPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Corte + Barba Completa',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${_planPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF667eea) : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
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
        // Aqui você pode mostrar um dialog ou navegar para uma tela específica
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIX gerado com sucesso! Aguardando pagamento...'),
            backgroundColor: Colors.green,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecionando para checkout Stripe...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      throw Exception('Erro ao processar pagamento: $e');
    }
  }
}