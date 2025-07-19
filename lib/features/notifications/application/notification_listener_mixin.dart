import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';

/// Provider que expõe o stream de ações de notificação
final notificationActionStreamProvider = StreamProvider.autoDispose<NotificationAction>((ref) {
  return ref.watch(notificationServiceProvider).actionStream;
});

/// Mixin para escutar ações de notificação e fornecer feedback ao usuário
mixin NotificationActionListenerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  
  @override
  void initState() {
    super.initState();
    _listenToNotificationActions();
  }
  
  /// Configura o listener para o stream de ações de notificação
  void _listenToNotificationActions() {
    // Escuta o provider, que gerencia o ciclo de vida do stream automaticamente
    ref.listen<AsyncValue<NotificationAction>>(
      notificationActionStreamProvider, 
      (_, next) {
        next.whenData(_handleNotificationAction);
      }
    );
  }
  
  /// Processa uma ação de notificação
  void _handleNotificationAction(NotificationAction action) {
    if (!mounted) return;
    
    // Determinar mensagem e cor com base no tipo de ação
    String message;
    Color backgroundColor;

    if (action.actionType == NotificationService.confirmAction) {
      message = 'Agendamento confirmado com sucesso!';
      backgroundColor = Colors.green;
    } else if (action.actionType == NotificationService.cancelAction) {
      message = 'Agendamento cancelado.';
      backgroundColor = Colors.orange;
    } else {
      message = 'Ação desconhecida processada.';
      backgroundColor = Colors.blue;
    }

    // Mostrar feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );

    // Chamar método para permitir que a tela realize ações específicas
    onNotificationActionProcessed(action);
  }

  /// Este método deve ser implementado pela tela para lidar com o resultado
  /// de uma ação de notificação, por exemplo, invalidando um provider.
  void onNotificationActionProcessed(NotificationAction action);
}