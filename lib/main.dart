import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env.prod");
  
  // Initialize services for production
  await ApiService().init();
  await AuthService().init();
  
  // Initialize notification service
  await NotificationService.instance.init();
  
  // Global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
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