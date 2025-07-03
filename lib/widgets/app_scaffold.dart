import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool isLoading;
  final String currentPath;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showBackButton = false,
    this.actions,
    this.isLoading = false,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    // final isTablet = size.width > 768 && size.width <= 1024;
    final isMobile = size.width <= 768;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: isMobile
          ? AppBar(
              title: Text(title, style: AppTextStyles.h4),
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : null,
              actions: actions,
            )
          : null,
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Row(
        children: [
          // Sidebar para desktop e tablet
          if (!isMobile) _buildSidebar(context, isDesktop),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // AppBar para desktop e tablet
                if (!isMobile)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(title, style: AppTextStyles.h4),
                        const Spacer(),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                
                // Conteúdo
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : body,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildSidebar(BuildContext context, bool isExpanded) {
    return Container(
      width: isExpanded ? 260 : 220,
      color: AppColors.white,
      child: Column(
        children: [
          // Logo
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('AgendeMais', style: AppTextStyles.logo),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botão de Novo Agendamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.buttonShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Implementar ação de novo agendamento
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Novo Agendamento',
                          style: AppTextStyles.buttonMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu de navegação
          _buildNavItem(
            context,
            'Dashboard',
            Icons.dashboard_outlined,
            AppRoutes.dashboard,
          ),
          _buildNavItem(
            context,
            'Gerar PIX',
            Icons.qr_code,
            AppRoutes.generatePix,
          ),
          _buildNavItem(
            context,
            'Histórico PIX',
            Icons.history,
            AppRoutes.pixHistory,
          ),
          _buildNavItem(
            context,
            'Configurações',
            Icons.settings_outlined,
            AppRoutes.settings,
          ),
          
          const Spacer(),
          
          // Perfil do usuário
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    'AB',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin@example.com',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    final isActive = currentPath == route;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.grey600,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: isActive
                      ? AppTextStyles.navItemActive
                      : AppTextStyles.navItem,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AgendeMais',
                    style: AppTextStyles.logo.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão de Novo Agendamento
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.buttonShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Implementar ação de novo agendamento
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Novo Agendamento',
                          style: AppTextStyles.buttonMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Menu de navegação
          _buildNavItem(
            context,
            'Dashboard',
            Icons.dashboard_outlined,
            AppRoutes.dashboard,
          ),
          _buildNavItem(
            context,
            'Gerar PIX',
            Icons.qr_code,
            AppRoutes.generatePix,
          ),
          _buildNavItem(
            context,
            'Histórico PIX',
            Icons.history,
            AppRoutes.pixHistory,
          ),
          _buildNavItem(
            context,
            'Configurações',
            Icons.settings_outlined,
            AppRoutes.settings,
          ),
          
          const Spacer(),
          
          // Perfil do usuário
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    'AB',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin@example.com',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}