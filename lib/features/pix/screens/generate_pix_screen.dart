import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';

class GeneratePixScreen extends StatefulWidget {
  const GeneratePixScreen({super.key});

  @override
  State<GeneratePixScreen> createState() => _GeneratePixScreenState();
}

class _GeneratePixScreenState extends State<GeneratePixScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;
  bool _pixGerado = false;
  Map<String, dynamic> _pixData = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _gerarPix() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simular geração de PIX
      await Future.delayed(const Duration(seconds: 1));

      final valor = double.parse(_valorController.text.replaceAll(',', '.'));

      setState(() {
        _pixGerado = true;
        _pixData = {
          'transaction_id': 'PIX${DateTime.now().millisecondsSinceEpoch}',
          'pix_code':
              '00020126580014BR.GOV.BCB.PIX0136a629532e-7693-4846-b028-f142082d7b8752040000530398654041.005802BR5925AgendeMais Tecnologia LTDA6009SAO PAULO62070503***63041D2D',
          'valor': valor,
          'vencimento': DateTime.now()
              .add(const Duration(days: 1))
              .toString()
              .substring(0, 10),
        };
      });

      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PIX: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copiarPix() {
    Clipboard.setData(ClipboardData(text: _pixData['pix_code']));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código PIX copiado para a área de transferência'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gerar QR Code PIX',
      currentPath: AppRoutes.generatePix,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _pixGerado ? _buildPixGerado() : _buildFormulario(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gerar QR Code PIX',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados abaixo para gerar um QR Code PIX para pagamento',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          InputField(
            label: 'Valor (R\$)',
            hint: '0,00',
            controller: _valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money,
            isRequired: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+[\,\.]?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o valor';
              }
              final valorNumerico = double.tryParse(value.replaceAll(',', '.'));
              if (valorNumerico == null || valorNumerico <= 0) {
                return 'Valor inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          InputField(
            label: 'Descrição',
            hint: 'Ex: Mensalidade Julho 2025',
            controller: _descricaoController,
            maxLines: 2,
            prefixIcon: Icons.description,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a descrição';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Gerar QR Code PIX',
            onPressed: _gerarPix,
            isLoading: _isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPixGerado() {
    return Column(
      children: [
        Text(
          'QR Code PIX Gerado',
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Compartilhe o QR Code abaixo para receber o pagamento',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // QR Code
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              QrImageView(
                data: _pixData['pix_code'],
                size: 200,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, error) {
                  return Center(
                    child: Text(
                      'Erro ao gerar QR Code: $error',
                      style: AppTextStyles.error,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Informações do PIX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pixBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Valor:', 'R\$ ${_valorController.text}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Vencimento:', _pixData['vencimento']),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        'ID da Transação:', _pixData['transaction_id']),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botões
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Copiar Código PIX',
                onPressed: _copiarPix,
                icon: Icons.copy,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: 'Gerar Novo',
                onPressed: () {
                  setState(() {
                    _pixGerado = false;
                    _valorController.clear();
                    _descricaoController.clear();
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                isOutlined: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Ver Histórico',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.pixHistory),
          isSecondary: true,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
