import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';

/// Mixin para adicionar escuta de ações de notificação em telas de agendamentos
mixin AppointmentsNotificationListener<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    // Garante que o listener seja adicionado após o primeiro build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToNotificationActions();
    });
  }
  
  void _listenToNotificationActions() {
    // Escutar ações de notificações
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.actionStream.listen(_handleNotificationAction);
  }
  
  void _handleNotificationAction(NotificationAction action) {
    if (!mounted) return;
    
    String message;
    Color backgroundColor;
    
    // Determinar mensagem com base no tipo de ação
    if (action.actionType == NotificationService.confirmAction) {
      message = 'Agendamento confirmado com sucesso!';
      backgroundColor = Colors.green;
    } else if (action.actionType == NotificationService.cancelAction) {
      message = 'Agendamento cancelado.';
      backgroundColor = Colors.orange;
    } else {
      return; // Ignorar ações desconhecidas
    }
    
    // Mostrar feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
    
    // Recarregar dados de agendamentos
    onNotificationActionProcessed();
  }
  
  /// Método a ser sobrescrito para atualizar dados após processamento de ação
  void onNotificationActionProcessed();
}