import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_model.dart';
import '../services/real_time_notification_service.dart';

/// Provider para o serviço de notificações em tempo real
final realTimeNotificationServiceProvider =
    Provider<RealTimeNotificationService>((ref) {
      return RealTimeNotificationService();
    });

class RealTimeNotificationWidget extends ConsumerStatefulWidget {
  const RealTimeNotificationWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<RealTimeNotificationWidget> createState() =>
      _RealTimeNotificationWidgetState();
}

class _RealTimeNotificationWidgetState
    extends ConsumerState<RealTimeNotificationWidget> {
  @override
  void initState() {
    super.initState();
    _startNotificationService();
  }

  void _startNotificationService() {
    final service = ref.read(realTimeNotificationServiceProvider);
    service.startPolling();
  }

  @override
  void dispose() {
    final service = ref.read(realTimeNotificationServiceProvider);
    service.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = ref.watch(realTimeNotificationServiceProvider);

    return StreamBuilder<NotificationModel>(
      stream: notificationService.notificationStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final notification = snapshot.data!;
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Implementar fechamento da notificação
          },
        ),
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.info:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case NotificationType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case NotificationType.appointment:
        iconData = Icons.calendar_today;
        iconColor = Colors.purple;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = Colors.teal;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withValues(alpha: 0.2),
      child: Icon(iconData, color: iconColor),
    );
  }
}
