import 'dart:async';
import 'package:flutter_application_1/core/services/api_service.dart';
import 'package:flutter_application_1/core/models/notification_model.dart';

/// Serviço responsável por gerenciar notificações em tempo real
class RealTimeNotificationService {
  final ApiService _apiService = ApiService();
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();
  Timer? _pollingTimer;
  DateTime _lastFetchTime = DateTime.now();
  bool _isPolling = false;

  /// Stream de notificações em tempo real
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  /// Inicia o polling de notificações
  void startPolling() {
    if (_isPolling) return;

    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchNewNotifications();
    });

    // Buscar notificações imediatamente ao iniciar
    _fetchNewNotifications();
  }

  /// Para o polling de notificações
  void stopPolling() {
    _pollingTimer?.cancel();
    _isPolling = false;
  }

  /// Busca novas notificações desde a última verificação
  Future<void> _fetchNewNotifications() async {
    try {
      final response = await _apiService.get('/notifications/unread');

      if (response['success'] == true) {
        final List<dynamic> notifications = response['data'] ?? [];

        for (final notificationJson in notifications) {
          final notification = NotificationModel.fromJson(notificationJson);

          // Verificar se a notificação é mais recente que a última verificação
          if (notification.createdAt.isAfter(_lastFetchTime)) {
            _notificationController.add(notification);
          }
        }

        _lastFetchTime = DateTime.now();
      }
    } catch (e) {
      print('Erro ao buscar notificações: $e');
    }
  }

  /// Marca uma notificação como lida
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put(
        '/notifications/$notificationId/read',
        body: {'read': true},
      );

      return response['success'] == true;
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
      return false;
    }
  }

  /// Marca todas as notificações como lidas
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.put(
        '/notifications/read-all',
        body: {},
      );

      return response['success'] == true;
    } catch (e) {
      print('Erro ao marcar todas notificações como lidas: $e');
      return false;
    }
  }

  /// Descarta os recursos
  void dispose() {
    stopPolling();
    _notificationController.close();
  }

  void _handleNotificationReceived(NotificationModel notification) {
    _notificationController.add(notification);
    print('Notificação recebida: ${notification.title}'); // TODO: Usar logger
  }

  void _handleNotificationError(String error) {
    print('Erro na notificação: $error'); // TODO: Usar logger
  }
}
