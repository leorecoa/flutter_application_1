import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI for production
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize critical services
  try {
    await _initializeServices();
  } catch (e) {
    debugPrint('🚨 Service initialization error: $e');
    // Continue startup but log the error
  }
  
  // Global error handling for production
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🚨 Flutter Error: ${details.exception}');
    debugPrint('🔍 Stack Trace: ${details.stack}');
    
    // In production, you might want to send this to a crash reporting service
    // FirebaseCrashlytics.instance.recordFlutterError(details);
  };
  
  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 Platform Error: $error');
    debugPrint('🔍 Stack Trace: $stack');
    return true;
  };
  
  runApp(const ProviderScope(child: AgendemaisApp()));
}

Future<void> _initializeServices() async {
  debugPrint('🚀 Initializing AGENDEMAIS services...');
  
  // Initialize API service
  try {
    await ApiService().init();
    debugPrint('✅ API Service initialized');
  } catch (e) {
    debugPrint('❌ API Service initialization failed: $e');
    rethrow;
  }
  
  // Initialize Auth service
  try {
    await AuthService().init();
    debugPrint('✅ Auth Service initialized');
  } catch (e) {
    debugPrint('❌ Auth Service initialization failed: $e');
    rethrow;
  }
  
  debugPrint('🎉 All services initialized successfully');
}

class AgendemaisApp extends StatelessWidget {
  const AgendemaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      
      // Router configuration with auth protection
      routerConfig: AppRouter.router,
      
      // Error handling
      builder: (context, child) {
        // Handle global widget errors
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return _buildErrorWidget(errorDetails);
        };
        
        return child ?? const _FallbackWidget();
      },
    );
  }

  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Algo deu errado',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por favor, reinicie o aplicativo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, you might want to restart or navigate to a safe screen
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Fechar App'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Detalhes do Erro (Debug)'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorDetails.exception.toString(),
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackWidget extends StatelessWidget {
  const _FallbackWidget();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando AGENDEMAIS...'),
            ],
          ),
        ),
      ),
    );
  }
}