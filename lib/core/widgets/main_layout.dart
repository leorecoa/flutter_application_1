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
            selectedIndex: _getSelectedIndex(context),
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
                icon: Icon(Icons.people),
                label: Text('Clientes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build),
                label: Text('Serviços'),
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
                label: Text('Config'),
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
        currentIndex: _getSelectedIndex(context),
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

  int _getSelectedIndex(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    if (isDesktop) {
      switch (currentPath) {
        case '/dashboard': return 0;
        case '/appointments': return 1;
        case '/clients': return 2;
        case '/services': return 3;
        case '/reports': return 4;
        case '/pix': return 5;
        case '/settings': return 6;
        default: return 0;
      }
    } else {
      switch (currentPath) {
        case '/dashboard': return 0;
        case '/appointments': return 1;
        case '/pix': return 2;
        case '/settings': return 3;
        default: return 0;
      }
    }
  }

  void _navigateToIndex(BuildContext context, int index) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    if (isDesktop) {
      switch (index) {
        case 0: context.go('/dashboard'); break;
        case 1: context.go('/appointments'); break;
        case 2: context.go('/clients'); break;
        case 3: context.go('/services'); break;
        case 4: context.go('/reports'); break;
        case 5: context.go('/pix'); break;
        case 6: context.go('/settings'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/dashboard'); break;
        case 1: context.go('/appointments'); break;
        case 2: context.go('/pix'); break;
        case 3: context.go('/settings'); break;
      }
    }
  }
}