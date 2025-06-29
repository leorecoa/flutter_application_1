import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';
import '../services/recibo_service.dart';
import '../../payments/models/payment_model.dart';

class TesteReciboScreen extends StatefulWidget {
  const TesteReciboScreen({super.key});

  @override
  State<TesteReciboScreen> createState() => _TesteReciboScreenState();
}

class _TesteReciboScreenState extends State<TesteReciboScreen> {
  bool _isProcessing = false;
  String _resultado = '';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Teste de Recibos Automáticos',
      currentRoute: '/admin/teste-recibo',
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          decoration: TrinksTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long,
                size: 64,
                color: TrinksTheme.navyBlue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Sistema de Recibos Automáticos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: TrinksTheme.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Teste o envio automático de recibos por email e WhatsApp após confirmação de pagamento.',
                style: TextStyle(
                  fontSize: 16,
                  color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildFeaturesList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _testarEnvioRecibo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: TrinksTheme.navyBlue,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processando...'),
                          ],
                        )
                      : const Text(
                          'Testar Envio de Recibo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              if (_resultado.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TrinksTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TrinksTheme.success),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: TrinksTheme.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Resultado do Teste',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: TrinksTheme.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _resultado,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Funcionalidades Testadas:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem('📄', 'Geração de PDF profissional'),
        _buildFeatureItem('📤', 'Upload para Amazon S3'),
        _buildFeatureItem('📧', 'Envio por email via SES'),
        _buildFeatureItem('📱', 'Envio por WhatsApp API'),
        _buildFeatureItem('🔐', 'Código de autenticação único'),
        _buildFeatureItem('⏰', 'Link com expiração de 24h'),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _testarEnvioRecibo() async {
    setState(() {
      _isProcessing = true;
      _resultado = '';
    });

    try {
      final paymentTeste = Payment(
        id: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        clienteNome: 'João Silva (Teste)',
        clienteId: 'cliente-teste-123',
        servicoNome: 'Corte + Barba',
        servicoId: 'servico-1',
        barbeiroNome: 'Carlos',
        barbeiroId: 'barbeiro-1',
        valor: 55.0,
        formaPagamento: FormaPagamento.pix,
        status: StatusPagamento.pago,
        data: DateTime.now(),
        observacoes: 'Teste do sistema de recibos automáticos',
      );

      final sucesso = await ReciboService.processarPagamentoConfirmado(paymentTeste);

      setState(() {
        _resultado = sucesso
            ? '''✅ Recibo processado com sucesso!

🔄 Etapas executadas:
• PDF gerado com dados da GAP Barber & Studio
• Arquivo enviado para Amazon S3
• Email enviado via Amazon SES
• Mensagem enviada via WhatsApp API
• Registro salvo no banco de dados

📧 Email: cliente@email.com
📱 WhatsApp: (81) 99999-9999
🔐 Código: GAP-${DateTime.now().year}-XXXX

Verifique o console para logs detalhados.'''
            : '❌ Erro ao processar recibo. Verifique o console para detalhes.';
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Erro inesperado: $e';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}