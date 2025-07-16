import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/features/auth/application/session_service.dart';

// Supondo que você tenha uma variável goRouter com suas rotas
// final GoRouter goRouter = GoRouter(routes: [ ... ]);

class MyApp extends ConsumerWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O GestureDetector irá detectar qualquer interação na tela
    return GestureDetector(
      onTap: () => _resetSessionTimer(context, ref),
      onPanDown: (_) => _resetSessionTimer(context, ref),
      onScaleStart: (_) => _resetSessionTimer(context, ref),
      // Adicione mais gestos se necessário

      child: MaterialApp.router(
        title: 'AgendaFácil',
        routerConfig: router,
        // outros parâmetros do seu MaterialApp...
      ),
    );
  }

  void _resetSessionTimer(BuildContext context, WidgetRef ref) {
    ref.read(sessionServiceProvider.notifier).resetTimer(context);
  }
}// No seu método de login, após receber o token...
ref.read(sessionServiceProvider.notifier).startTimer(context);
// No seu método de logout...
ref.read(sessionServiceProvider.notifier).stopTimer();
