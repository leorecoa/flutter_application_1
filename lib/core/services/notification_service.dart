import 'dart:async';
import '../models/notification_model.dart';
import '../models/appointment_model.dart';

/// Serviço para gerenciar notificações
class NotificationService {
  final StreamController<NotificationActionEvent> _actionController =
      StreamController<NotificationActionEvent>.broadcast();

  /// Stream de ações de notificação
  Stream<NotificationActionEvent> get actionStream => _actionController.stream;

  /// Confirma uma ação de notificação
  void confirmAction(String notificationId) {
    _actionController.add(
      NotificationActionEvent(
        notificationId: notificationId,
        action: 'confirm',
      ),
    );
  }

  /// Cancela uma ação de notificação
  void cancelAction(String notificationId) {
    _actionController.add(
      NotificationActionEvent(notificationId: notificationId, action: 'cancel'),
    );
  }

  /// Agenda lembretes de agendamento
  Future<void> scheduleAppointmentReminders(Appointment appointment) async {
    // Implementação mock
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Cancela notificações de agendamento
  Future<void> cancelAppointmentNotifications(String appointmentId) async {
    // Implementação mock
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Descarta os recursos
  void dispose() {
    _actionController.close();
  }
}

/// Evento de ação de notificação
class NotificationActionEvent {
  final String notificationId;
  final String action; // Mudando para String para evitar conflito

  const NotificationActionEvent({
    required this.notificationId,
    required this.action,
  });
}
