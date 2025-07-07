import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _getSelectedIndex(),
            onDestinationSelected: (index) => _navigateToIndex(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Agendamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Relatórios'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.qr_code),
                label: Text('PIX'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Configurações'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getSelectedIndex(),
        onTap: (index) => _navigateToIndex(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'PIX',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex() {
    switch (currentPath) {
      case '/dashboard':
        return 0;
      case '/appointments':
        return 1;
      case '/reports':
        return 2;
      case '/pix':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/appointments');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/pix');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}