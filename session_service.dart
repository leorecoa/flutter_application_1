import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define um provedor global para nosso serviço de sessão
final sessionServiceProvider =
    StateNotifierProvider<SessionTimerService, Timer?>((ref) {
      return SessionTimerService(ref);
    });

class SessionTimerService extends StateNotifier<Timer?> {
  final Ref _ref;
  // Define o tempo de inatividade em 15 minutos
  static const _sessionTimeout = Duration(minutes: 15);

  SessionTimerService(this._ref) : super(null);

  void startTimer(BuildContext context) {
    // Cancela qualquer timer anterior
    state?.cancel();
    // Inicia um novo timer
    state = Timer(_sessionTimeout, () => _logout(context));
    debugPrint('Session timer started.');
  }

  void resetTimer(BuildContext context) {
    // Se não houver timer, não faz nada (usuário não está logado)
    if (state == null || !state!.isActive) return;

    // Reinicia o timer
    state?.cancel();
    state = Timer(_sessionTimeout, () => _logout(context));
    debugPrint('Session timer reset due to user activity.');
  }

  void stopTimer() {
    state?.cancel();
    state = null;
    debugPrint('Session timer stopped.');
  }

  Future<void> _logout(BuildContext context) async {
    debugPrint('Session timed out. Logging out...');
    stopTimer();
    // Limpa os dados da sessão (ex: token salvo)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Use a chave correta do seu token

    // Navega para a tela de login
    if (context.mounted) {
      context.go('/login');
    }
  }
}
