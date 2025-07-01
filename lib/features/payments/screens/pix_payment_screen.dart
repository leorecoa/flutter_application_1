import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
// ...existing code...
// import 'dart:typed_data';
// ...existing code...import 'dart:typed_data';
import '../models/pix_payment_model.dart';
import '../services/pix_service.dart';

class PixPaymentScreen extends StatefulWidget {
  final double amount;
  final String description;

  const PixPaymentScreen({
    super.key,
    required this.amount,
    required this.description,
  });

  @override
  State<PixPaymentScreen> createState() => _PixPaymentScreenState();
}

class _PixPaymentScreenState extends State<PixPaymentScreen> {
  PixPayment? _pixPayment;
  bool _isLoading = false;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _createPixPayment();
  }

  Future<void> _createPixPayment() async {
    setState(() => _isLoading = true);

    try {
      final payment = await PixService.createPixPayment(
        amount: widget.amount,
        description: widget.description,
        email: 'cliente@email.com',
        name: 'Cliente Teste',
        tenantId: 'tenant-123',
      );

      setState(() {
        _pixPayment = payment;
        _isLoading = false;
      });

      _startStatusCheck();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao gerar PIX: $e');
    }
  }

  void _startStatusCheck() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (_pixPayment != null && !_pixPayment!.isPaid && mounted) {
        await _checkPaymentStatus();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;

    setState(() => _isCheckingStatus = true);

    try {
      final status =
          await PixService.checkPaymentStatus(_pixPayment!.paymentId);

      if (status == 'approved') {
        _showSuccess();
      } else if (mounted) {
        setState(() => _isCheckingStatus = false);
        _startStatusCheck();
      }
    } catch (e) {
      setState(() => _isCheckingStatus = false);
      _startStatusCheck();
    }
  }

  void _copyPixCode() {
    if (_pixPayment?.pixCode != null) {
      Clipboard.setData(ClipboardData(text: _pixPayment!.pixCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código PIX copiado!')),
      );
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ Pagamento Aprovado!'),
        content: const Text('Seu pagamento PIX foi confirmado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento PIX'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pixPayment == null
              ? const Center(child: Text('Erro ao gerar PIX'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.pix,
                                  size: 48, color: Colors.green),
                              const SizedBox(height: 16),
                              Text(
                                'R\$ ${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(widget.description),
                              const SizedBox(height: 16),
                              if (_pixPayment!.pixQrCodeBase64 != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.memory(
                                    base64Decode(_pixPayment!.pixQrCodeBase64!),
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (_pixPayment!.pixCode != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _pixPayment!.pixCode!,
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'monospace'),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _copyPixCode,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copiar Código PIX'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (_isCheckingStatus)
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Verificando pagamento...'),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Como pagar:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('1. Abra o app do seu banco'),
                              Text('2. Escolha a opção PIX'),
                              Text('3. Escaneie o QR Code ou cole o código'),
                              Text('4. Confirme o pagamento'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
