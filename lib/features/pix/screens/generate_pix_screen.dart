import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/input_field.dart';

class GeneratePixScreen extends StatefulWidget {
  const GeneratePixScreen({super.key});

  @override
  State<GeneratePixScreen> createState() => _GeneratePixScreenState();
}

class _GeneratePixScreenState extends State<GeneratePixScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empresaIdController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _pixData;

  Future<void> _generatePix() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _pixData = {
          'transaction_id': 'abc123def456',
          'pix_code': '00020126580014BR.GOV.BCB.PIX0136123e4567-e12b-12d1-a456-426655440000520400005303986540599.905802BR5913AGENDEMAIS SAS6009SAO PAULO62070503***6304ABCD',
          'valor': double.parse(_valorController.text.replaceAll(',', '.')),
          'vencimento': '2025-08-01',
        };
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code PIX gerado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PIX: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyPixCode() {
    if (_pixData?['pix_code'] != null) {
      Clipboard.setData(ClipboardData(text: _pixData!['pix_code']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX copiado!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerar QR Code PIX', style: AppTextStyles.h4),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dados da Cobrança', style: AppTextStyles.h5),
                      const SizedBox(height: 24),
                      
                      InputField(
                        label: 'ID da Empresa',
                        hint: 'Ex: clinica-abc-123',
                        controller: _empresaIdController,
                        prefixIcon: Icons.business,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'ID da empresa é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      InputField(
                        label: 'Valor (R\$)',
                        hint: '99,90',
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Valor é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      InputField(
                        label: 'Descrição',
                        hint: 'Ex: Mensalidade Julho 2025',
                        controller: _descricaoController,
                        prefixIcon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Descrição é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      PrimaryButton(
                        text: 'Gerar QR Code PIX',
                        icon: Icons.qr_code,
                        onPressed: _generatePix,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_pixData != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('QR Code PIX Gerado', style: AppTextStyles.h5),
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: QrImageView(
                          data: _pixData!['pix_code'],
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      PrimaryButton(
                        text: 'Copiar Código PIX',
                        icon: Icons.copy,
                        onPressed: _copyPixCode,
                        width: double.infinity,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}