import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_action_event.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';
import '../../appointments/application/appointment_providers.dart';

/// Mixin para escutar ações de notificação e fornecer feedback ao usuário
mixin NotificationActionListener<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    // Garante que o listener seja adicionado após o primeiro frame ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToNotificationActions();
    });
  }

  void _listenToNotificationActions() {
    // Escutar o stream de ações de notificação
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.actionStream.listen(_handleNotificationAction);
  }
  
  void _handleNotificationAction(NotificationAction action) {
    if (!mounted) return;
    
    // Determinar mensagem e cor com base no tipo de ação
    String message;
    Color backgroundColor;
    NotificationActionEvent event;
    
    if (action.actionType == NotificationService.confirmAction) {
      message = 'Agendamento confirmado com sucesso!';
      backgroundColor = Colors.green;
      event = NotificationActionEvent.confirmed;
    } else if (action.actionType == NotificationService.cancelAction) {
      message = 'Agendamento cancelado.';
      backgroundColor = Colors.orange;
      event = NotificationActionEvent.cancelled;
    } else {
      message = 'Ação desconhecida processada.';
      backgroundColor = Colors.blue;
      event = NotificationActionEvent.error;
    }
    
    // Mostrar feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
    
    // Chamar método para permitir que a tela realize ações específicas
    onNotificationActionProcessed(event);
  }
  
  /// Este método deve ser implementado pela tela para lidar com o resultado
  /// de uma ação de notificação, por exemplo, invalidando um provider.
  void onNotificationActionProcessed(NotificationActionEvent event);
}