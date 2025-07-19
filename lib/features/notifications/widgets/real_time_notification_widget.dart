import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_model.dart';
import '../services/real_time_notification_service.dart';

class RealTimeNotificationWidget extends ConsumerStatefulWidget {
  final Widget child;

  const RealTimeNotificationWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<RealTimeNotificationWidget> createState() => _RealTimeNotificationWidgetState();
}

class _RealTimeNotificationWidgetState extends ConsumerState<RealTimeNotificationWidget> {
  OverlayEntry? _overlayEntry;
  bool _isShowingNotification = false;

  @override
  void initState() {
    super.initState();
    
    // Iniciar o serviço de notificações em tempo real
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(realTimeNotificationServiceProvider);
      service.startPolling();
      
      // Escutar por novas notificações
      service.notificationStream.listen(_showNotification);
    });
  }

  @override
  void dispose() {
    // Parar o serviço de notificações em tempo real
    ref.read(realTimeNotificationServiceProvider).stopPolling();
    _removeCurrentNotification();
    super.dispose();
  }

  void _showNotification(NotificationModel notification) {
    // Remover notificação atual se existir
    _removeCurrentNotification();
    
    // Criar nova notificação
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildNotificationWidget(notification),
    );
    
    // Mostrar notificação
    _isShowingNotification = true;
    Overlay.of(context).insert(_overlayEntry!);
    
    // Remover após 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      _removeCurrentNotification();
    });
  }

  void _removeCurrentNotification() {
    if (_isShowingNotification && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowingNotification = false;
    }
  }

  Widget _buildNotificationWidget(NotificationModel notification) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      left: 10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Marcar como lida e remover
            ref.read(realTimeNotificationServiceProvider).markAsRead(notification.id);
            _removeCurrentNotification();
            
            // Navegar para a tela apropriada com base no tipo de notificação
            if (notification.type == NotificationType.appointment) {
              // Implementar navegação para detalhes do agendamento
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _removeCurrentNotification,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.system:
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}