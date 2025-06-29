import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isSelected;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isSelected = false,
  });

  MenuItem copyWith({bool? isSelected}) {
    return MenuItem(
      title: title,
      icon: icon,
      route: route,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}