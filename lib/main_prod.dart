import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/services/error_reporting_service.dart';
import 'core/config/aws_config.dart';

/// Ponto de entrada para o ambiente de produção
void main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega variáveis de ambiente
  await dotenv.load(fileName: '.env.prod');
  
  // Inicializa serviço de relatório de erros
  ErrorReportingService.init();
  
  // Inicia o aplicativo
  runApp(const ProviderScope(child: AgendeMaisApp()));
}

class AgendeMaisApp extends StatelessWidget {
  const AgendeMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgendeMais - Seu tempo, seu agendamento',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.grey50,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}