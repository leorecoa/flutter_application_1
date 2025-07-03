import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _pixKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simular cadastro
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: isDesktop ? 500 : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go(AppRoutes.login),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Criar Conta',
                            style: AppTextStyles.h3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Campos
                    InputField(
                      label: 'Nome da Empresa',
                      hint: 'Ex: Clínica Bella Vista',
                      controller: _nomeController,
                      prefixIcon: Icons.business,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nome da empresa é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    InputField(
                      label: 'E-mail',
                      hint: 'contato@empresa.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'E-mail é obrigatório';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value!)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    InputField(
                      label: 'CNPJ',
                      hint: '00.000.000/0001-00',
                      controller: _cnpjController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.badge,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'CNPJ é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    InputField(
                      label: 'Chave PIX',
                      hint: 'CPF, CNPJ, e-mail ou telefone',
                      controller: _pixKeyController,
                      prefixIcon: Icons.pix,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Chave PIX é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    InputField(
                      label: 'Senha',
                      hint: 'Mínimo 6 caracteres',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Senha é obrigatória';
                        }
                        if (value!.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botão Cadastrar
                    PrimaryButton(
                      text: 'Criar Conta',
                      onPressed: _handleSignup,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 24),

                    // Termos
                    Text(
                      'Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
