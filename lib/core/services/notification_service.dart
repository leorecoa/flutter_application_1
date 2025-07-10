import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<Function(AppNotification)> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addListener(Function(AppNotification) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(AppNotification) listener) {
    _listeners.remove(listener);
  }

  Future<void> initialize() async {
    await _loadNotifications();
    _generateSampleNotifications();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _saveNotifications();
    for (final listener in _listeners) {
      listener(notification);
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveNotifications();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    
    _notifications.clear();
    for (final json in notificationsJson) {
      try {
        // Simplified loading - in real app would parse JSON
        _notifications.add(AppNotification.sample());
      } catch (e) {
        // Ignore invalid notifications
      }
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => n.id).toList();
    await prefs.setStringList('notifications', notificationsJson);
  }

  void _generateSampleNotifications() {
    if (_notifications.isEmpty) {
      addNotification(AppNotification(
        id: '1',
        title: 'Novo agendamento',
        message: 'Maria Silva agendou um corte para hoje às 14:00',
        type: NotificationType.appointment,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ));
      
      addNotification(AppNotification(
        id: '2',
        title: 'Pagamento recebido',
        message: 'Pagamento de R\$ 85,00 via PIX confirmado',
        type: NotificationType.payment,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ));
      
      addNotification(AppNotification(
        id: '3',
        title: 'Lembrete',
        message: 'Você tem 3 agendamentos para amanhã',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ));
    }
  }
}

enum NotificationType { appointment, payment, reminder, system }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  static AppNotification sample() {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Notificação de exemplo',
      message: 'Esta é uma notificação de exemplo',
      type: NotificationType.system,
      timestamp: DateTime.now(),
    );
  }
}