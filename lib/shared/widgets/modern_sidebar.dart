import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/trinks_theme.dart';

class ModernSidebar extends StatelessWidget {
  final String currentRoute;

  const ModernSidebar({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: TrinksTheme.white,
        boxShadow: [
          BoxShadow(
            color: TrinksTheme.darkGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TrinksTheme.navyBlue, TrinksTheme.purple],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AgendaFácil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TrinksTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Agendamentos',
                  route: '/appointments',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.build_outlined,
                  activeIcon: Icons.build,
                  title: 'Serviços',
                  route: '/services',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Clientes',
                  route: '/clients',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profissionais',
                  route: '/professionals',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  title: 'Relatórios',
                  route: '/reports',
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  title: 'Configurações',
                  route: '/settings',
                ),
              ],
            ),
          ),

          // User Profile
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: TrinksTheme.lightPurple,
                  child: Icon(Icons.person, color: TrinksTheme.purple),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'João Silva',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TrinksTheme.darkGray,
                        ),
                      ),
                      Text(
                        'Plano Premium',
                        style: TextStyle(
                          fontSize: 12,
                          color: TrinksTheme.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: TrinksTheme.darkGray),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? TrinksTheme.navyBlue : TrinksTheme.darkGray,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? TrinksTheme.navyBlue : TrinksTheme.darkGray,
          ),
        ),
        selected: isActive,
        selectedTileColor: TrinksTheme.navyBlue.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => context.go(route),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
