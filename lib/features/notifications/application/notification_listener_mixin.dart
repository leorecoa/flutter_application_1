import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';

/// Provider que expõe o stream de ações de notificação, desacoplando a UI do serviço.
/// O autoDispose garante que o stream seja fechado quando não for mais ouvido.
final notificationActionStreamProvider =
    StreamProvider.autoDispose<NotificationAction>((ref) {
  return ref.watch(notificationServiceProvider).actionStream;
});

/// Mixin para escutar ações de notificação e fornecer feedback ao usuário
mixin NotificationActionListenerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    // Garante que o listener seja adicionado após o primeiro frame ser construído
    _listenToNotificationActions();
  }

  void _listenToNotificationActions() {
    // Escuta o provider, que gerencia o ciclo de vida do stream automaticamente.
    ref.listen<AsyncValue<NotificationAction>>(notificationActionStreamProvider,
        (_, next) {
      // Apenas processa o evento se houver dados (ignora loading/error do stream)
      next.whenData(_handleNotificationAction);
    });
  }

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
