import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Agendamento Confirmado',
      'message': 'João Silva confirmou o agendamento para amanhã às 14:00',
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
      'type': 'confirmation',
    },
    {
      'id': '2',
      'title': 'Lembrete',
      'message': 'Você tem 3 agendamentos hoje',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': true,
      'type': 'reminder',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (_notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas como lidas'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhuma notificação'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification['isRead'] ? Colors.grey : Colors.blue,
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification['time']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _markAsRead(notification['id']),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'confirmation':
        return Icons.check_circle;
      case 'reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }
}