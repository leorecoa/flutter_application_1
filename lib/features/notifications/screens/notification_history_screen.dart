import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/notification_history_model.dart';
import '../services/notification_history_service.dart';

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationHistoryAsync = ref.watch(notificationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(context, ref),
            tooltip: 'Limpar histórico',
          ),
        ],
      ),
      body: notificationHistoryAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma notificação no histórico'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(context, ref, notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erro ao carregar notificações: $error'),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationHistoryItem notification,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
          child: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () {
          // Marcar como lida
          if (!notification.isRead) {
            ref
                .read(notificationHistoryServiceProvider)
                .markAsRead(notification.id);
            ref.refresh(notificationHistoryProvider);
          }

          // Navegar para detalhes do agendamento se disponível
          if (notification.appointmentId != null) {
            context.push('/appointment-details/${notification.appointmentId}');
          }
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text(
          'Tem certeza que deseja limpar todo o histórico de notificações?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(notificationHistoryServiceProvider).clearHistory();
              ref.refresh(notificationHistoryProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Histórico de notificações limpo'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
