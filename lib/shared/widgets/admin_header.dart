import 'package:flutter/material.dart';
import '../../core/theme/trinks_theme.dart';

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userName;

  const AdminHeader({
    super.key,
    required this.title,
    this.userName = 'Administrador',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TrinksTheme.white,
        boxShadow: [
          BoxShadow(
            color: TrinksTheme.darkGray.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: const TextStyle(
            color: TrinksTheme.darkGray,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _buildNotificationButton(),
          const SizedBox(width: 16),
          _buildUserProfile(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: TrinksTheme.darkGray),
          onPressed: () {},
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: TrinksTheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: TrinksTheme.lightPurple,
            child: Text(
              userName[0].toUpperCase(),
              style: const TextStyle(
                color: TrinksTheme.navyBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            userName,
            style: const TextStyle(
              color: TrinksTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: TrinksTheme.darkGray),
        ],
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 12),
              Text('Perfil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 12),
              Text('Configurações'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 18, color: TrinksTheme.error),
              SizedBox(width: 12),
              Text('Sair', style: TextStyle(color: TrinksTheme.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'logout':
            // Implementar logout
            break;
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}