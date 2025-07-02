import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/input_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController(text: 'Clínica Bella Vista');
  final _emailController = TextEditingController(text: 'contato@bellavista.com');
  final _pixKeyController = TextEditingController(text: '05359566493');
  final _senhaController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair da Conta', style: AppTextStyles.h5),
        content: Text(
          'Tem certeza que deseja sair?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.labelMedium),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: Text(
              'Sair',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações', style: AppTextStyles.h4),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Dados da Empresa
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dados da Empresa', style: AppTextStyles.h5),
                      const SizedBox(height: 24),
                      
                      InputField(
                        label: 'Nome da Empresa',
                        controller: _nomeController,
                        prefixIcon: Icons.business,
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'E-mail é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      InputField(
                        label: 'Chave PIX',
                        controller: _pixKeyController,
                        prefixIcon: Icons.pix,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Chave PIX é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      PrimaryButton(
                        text: 'Salvar Alterações',
                        icon: Icons.save,
                        onPressed: _saveSettings,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Segurança
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Segurança', style: AppTextStyles.h5),
                    const SizedBox(height: 24),
                    
                    InputField(
                      label: 'Nova Senha',
                      hint: 'Deixe em branco para manter a atual',
                      controller: _senhaController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 32),
                    
                    PrimaryButton(
                      text: 'Alterar Senha',
                      icon: Icons.security,
                      onPressed: () {
                        // Implementar alteração de senha
                      },
                      width: double.infinity,
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Ações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conta', style: AppTextStyles.h5),
                    const SizedBox(height: 24),
                    
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppColors.primary),
                      title: Text('Ajuda e Suporte', style: AppTextStyles.labelLarge),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Implementar ajuda
                      },
                    ),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.description, color: AppColors.primary),
                      title: Text('Termos de Uso', style: AppTextStyles.labelLarge),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Implementar termos
                      },
                    ),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: Text(
                        'Sair da Conta',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Versão
            Text(
              'AgendeMais v1.0.0',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}