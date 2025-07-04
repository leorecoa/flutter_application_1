import 'package:flutter/material.dart';

import '../../core/theme/trinks_theme.dart';
import 'admin_header.dart';
import 'admin_sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String currentRoute;
  final Widget? floatingActionButton;

  const AdminLayout({
    required this.child,
    required this.title,
    required this.currentRoute,
    super.key,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrinksTheme.lightGray,
      body: Row(
        children: [
          AdminSidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                AdminHeader(title: title),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
