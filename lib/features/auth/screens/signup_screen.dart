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

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
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
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simular cadastro
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer cadastro: $e'),
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
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.grey50,
              AppColors.grey100,
              AppColors.primary.withAlpha(13), // 5% opacity
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: isDesktop ? 520 : (isTablet ? 480 : double.infinity),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(76), // 30% opacity
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppColors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Título
                        Text('Criar Conta', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(
                          'Preencha os dados abaixo para criar sua conta',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Campos
                        InputField(
                          label: 'Nome da Empresa',
                          hint: 'Digite o nome da sua empresa',
                          controller: _nomeController,
                          prefixIcon: Icons.business,
                          isRequired: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        InputField(
                          label: 'E-mail',
                          hint: 'Digite seu e-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          isRequired: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'E-mail é obrigatório';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        InputField(
                          label: 'Senha',
                          hint: 'Digite sua senha',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          isRequired: true,
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
                        const SizedBox(height: 20),
                        
                        InputField(
                          label: 'Confirmar Senha',
                          hint: 'Confirme sua senha',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          isRequired: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Confirmação de senha é obrigatória';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
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
                        
                        // Link Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem conta? ',
                              style: AppTextStyles.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.login),
                              child: Text(
                                'Faça login',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}