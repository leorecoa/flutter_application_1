/// Modelo para representar uma ação de notificação
class NotificationAction {
  final String appointmentId;
  final String actionType;
  
  const NotificationAction({
    required this.appointmentId,
    required this.actionType,
  });
}