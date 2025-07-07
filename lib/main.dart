import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await ApiService().init();
  
  // Error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  runApp(const ProviderScope(child: AgendemaisApp()));
}

class AgendemaisApp extends StatelessWidget {
  const AgendemaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}