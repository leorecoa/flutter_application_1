import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _pixKeyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _loadSettings();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _pixKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      // Simular carregamento de configurações
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _nomeController.text = 'Clínica Bella Vista';
        _emailController.text = 'contato@bellavista.com';
        _pixKeyController.text = '05359566493';
      });

      _animationController.forward();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar configurações: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Simular salvamento de configurações
      await Future.delayed(const Duration(seconds: 1));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar configurações: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Configurações',
      currentPath: AppRoutes.settings,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie as configurações da sua conta',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Seção de Perfil
            _buildSection(
              title: 'Perfil da Empresa',
              icon: Icons.business,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value!)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      label: 'Chave PIX',
                      hint: 'Digite sua chave PIX',
                      controller: _pixKeyController,
                      prefixIcon: Icons.qr_code,
                      isRequired: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Chave PIX é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Salvar Alterações',
                      onPressed: _saveSettings,
                      isLoading: _isSaving,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seção de Segurança
            _buildSection(
              title: 'Segurança',
              icon: Icons.security,
              child: Column(
                children: [
                  _buildSettingItem(
                    title: 'Alterar Senha',
                    subtitle: 'Altere sua senha de acesso',
                    icon: Icons.lock_outline,
                    onTap: () {
                      // Implementar alteração de senha
                    },
                  ),
                  const Divider(),
                  _buildSettingItem(
                    title: 'Autenticação de Dois Fatores',
                    subtitle: 'Ative a verificação em duas etapas',
                    icon: Icons.verified_user_outlined,
                    onTap: () {
                      // Implementar 2FA
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção de Plano
            _buildSection(
              title: 'Plano e Assinatura',
              icon: Icons.card_membership,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(13), // 5% opacity
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withAlpha(25), // 10% opacity
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plano Premium',
                                style: AppTextStyles.cardTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Válido até 31/12/2025',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.success.withAlpha(25), // 10% opacity
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Ativo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Gerenciar Assinatura',
                    onPressed: () {
                      // Implementar gerenciamento de assinatura
                    },
                    isOutlined: true,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção de Conta
            _buildSection(
              title: 'Conta',
              icon: Icons.account_circle,
              child: Column(
                children: [
                  _buildSettingItem(
                    title: 'Exportar Dados',
                    subtitle: 'Baixe seus dados em formato CSV',
                    icon: Icons.download,
                    onTap: () {
                      // Implementar exportação de dados
                    },
                  ),
                  const Divider(),
                  _buildSettingItem(
                    title: 'Sair',
                    subtitle: 'Encerrar sessão atual',
                    icon: Icons.logout,
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () => context.go(AppRoutes.login),
                  ),
                  const Divider(),
                  _buildSettingItem(
                    title: 'Excluir Conta',
                    subtitle: 'Remover permanentemente sua conta',
                    icon: Icons.delete_forever,
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () {
                      // Implementar exclusão de conta
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(13), // 5% opacity
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.h5,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary)
                    .withAlpha(13), // 5% opacity
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: textColor ?? AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
