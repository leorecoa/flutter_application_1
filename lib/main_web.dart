import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/trinks_theme.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgendaFácil',
      theme: TrinksTheme.modernTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}