import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/luxury_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/services/amplify_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await AmplifyService.configureAmplify();
  } catch (e) {
    print('Error configuring Amplify: $e');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgendaFácil',
      theme: LuxuryTheme.luxuryTheme,
      darkTheme: LuxuryTheme.luxuryTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}