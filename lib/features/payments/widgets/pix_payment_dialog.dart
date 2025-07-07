import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pagamento_service.dart';

class PixPaymentDialog extends StatefulWidget {
  final Map<String, dynamic> pixData;
  final VoidCallback onPaymentCompleted;

  const PixPaymentDialog({
    super.key,
    required this.pixData,
    required this.onPaymentCompleted,
  });

  @override
  State<PixPaymentDialog> createState() => _PixPaymentDialogState();
}

class _PixPaymentDialogState extends State<PixPaymentDialog> {
  final _pagamentoService = PagamentoService();
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;
  int _timeRemaining = 1800; // 30 minutos
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
    _startCountdown();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkPaymentStatus();
    });
  }

  void _startCountdown() {
    final expiresAt = widget.pixData['expiresAt'];
    if (expiresAt != null) {
      final expiry = DateTime.parse(expiresAt);
      final now = DateTime.now();
      final diff = expiry.difference(now);
      _timeRemaining = diff.inSeconds > 0 ? diff.inSeconds : 0;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            timer.cancel();
            _showExpiredDialog();
          }
        });
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;
    
    setState(() => _isCheckingStatus = true);
    
    try {
      final transacaoId = widget.pixData['transacaoId'];
      if (transacaoId != null) {
        final statusData = await _pagamentoService.verificarStatusPagamento(transacaoId);
        
        if (statusData != null && statusData['status'] == 'pago' && mounted) {
          _statusCheckTimer?.cancel();
          _countdownTimer?.cancel();
          widget.onPaymentCompleted();
        }
      }
    } catch (e) {
      // Silencioso - continua verificando
      print('Erro ao verificar status: $e');
    } finally {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  void _showExpiredDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.timer_off, color: Colors.orange, size: 48),
        title: const Text('PIX Expirado'),
        content: const Text(
          'O código PIX expirou. Gere um novo código para continuar com o pagamento.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog de expiração
              Navigator.of(context).pop(); // Fechar dialog do PIX
            },
            child: const Text('Gerar Novo PIX'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _copyPixCode() {
    final pixCode = widget.pixData['codigoCopiaECola'];
    if (pixCode != null) {
      Clipboard.setData(ClipboardData(text: pixCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX não disponível'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pixCode = widget.pixData['codigoCopiaECola'] ?? '';
    final valor = widget.pixData['valor'] ?? 0.0;
    final descricao = widget.pixData['descricao'] ?? '';
    final nomeBeneficiario = widget.pixData['nomeBeneficiario'] ?? '';
    final chavePix = widget.pixData['chavePix'] ?? '';
    final banco = widget.pixData['banco'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pix,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pagamento PIX',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Valor e Descrição
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'R\$ ${valor.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dados PIX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        banco,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nomeBeneficiario,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PIX: $chavePix',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeRemaining < 300 ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _timeRemaining < 300 ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expira em ${_formatTime(_timeRemaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining < 300 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR Code ou Placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.pixData['qrCode'] != null && widget.pixData['qrCode'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.pixData['qrCode'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildQrPlaceholder(),
                      ),
                    )
                  : _buildQrPlaceholder(),
            ),

            const SizedBox(height: 20),

            // Instruções
            const Text(
              '1. Abra o app do seu banco\n'
              '2. Acesse a área PIX\n'
              '3. Escolha "Pagar com QR Code" ou "Copia e Cola"\n'
              '4. Escaneie o código ou cole o texto abaixo\n'
              '5. Confirme o pagamento',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Código PIX
            if (pixCode.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Código PIX (Copia e Cola):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pixCode,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botão Copiar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _copyPixCode,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar Código PIX'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],

            // Status Check Indicator
            if (_isCheckingStatus) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Verificando pagamento...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Info adicional
            Text(
              'O status do pagamento será atualizado automaticamente',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 8),
        Text(
          'QR Code PIX',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '(Use o código copia e cola abaixo)',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}