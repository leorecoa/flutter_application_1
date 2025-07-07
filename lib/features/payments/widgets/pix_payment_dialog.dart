import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pix/services/pix_service.dart';

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
  final _pixService = PixService();
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;
  int _timeRemaining = 300; // 5 minutos
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
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkPaymentStatus();
    });
  }

  void _startCountdown() {
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
      final paymentId = widget.pixData['paymentId'];
      if (paymentId != null) {
        final statusData = await _pixService.checkPaymentStatus(paymentId);
        
        if (statusData['status'] == 'paid' && mounted) {
          _statusCheckTimer?.cancel();
          _countdownTimer?.cancel();
          widget.onPaymentCompleted();
        }
      }
    } catch (e) {
      // Silencioso - continua verificando
    } finally {
      if (mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  void _showExpiredDialog() {
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
    final pixCode = widget.pixData['qr_code'];
    if (pixCode != null) {
      Clipboard.setData(ClipboardData(text: pixCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pixCode = widget.pixData['qr_code'] ?? '';
    final amount = widget.pixData['amount'] ?? 0.0;
    final description = widget.pixData['description'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                    'R\$ ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeRemaining < 60 ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _timeRemaining < 60 ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expira em ${_formatTime(_timeRemaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _timeRemaining < 60 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR Code (Placeholder)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.pixData['qr_code_image'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.pixData['qr_code_image'],
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
              '2. Escaneie o QR Code ou copie o código\n'
              '3. Confirme o pagamento',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Código PIX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
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
                    maxLines: 3,
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
      ],
    );
  }
}