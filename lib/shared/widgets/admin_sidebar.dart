import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/trinks_theme.dart';
import '../models/menu_item.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({required this.currentRoute, super.key});

  static const List<MenuItem> menuItems = [
    MenuItem(
        title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/admin'),
    MenuItem(
        title: 'Agendamentos',
        icon: Icons.calendar_today_outlined,
        route: '/admin/appointments'),
    MenuItem(
        title: 'Clientes', icon: Icons.people_outline, route: '/admin/clients'),
    MenuItem(
        title: 'Serviços',
        icon: Icons.content_cut_outlined,
        route: '/admin/services'),
    MenuItem(
        title: 'Financeiro',
        icon: Icons.attach_money_outlined,
        route: '/admin/financial'),
    MenuItem(
        title: 'Dashboard Financeiro',
        icon: Icons.analytics_outlined,
        route: '/admin/dashboard-financeiro'),
    MenuItem(
        title: 'Configurações',
        icon: Icons.settings_outlined,
        route: '/admin/settings'),
  ];

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
          _buildHeader(),
          Expanded(child: _buildMenu(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: TrinksTheme.navyBlue,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TrinksTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.content_cut,
                color: TrinksTheme.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'AgendaFácil',
            style: TextStyle(
              color: TrinksTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = currentRoute == item.route;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: isSelected ? TrinksTheme.navyBlue : TrinksTheme.darkGray,
              size: 22,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: isSelected ? TrinksTheme.navyBlue : TrinksTheme.darkGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            selected: isSelected,
            selectedTileColor: TrinksTheme.lightPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () => context.go(item.route),
          ),
        );
      },
    );
  }
}
