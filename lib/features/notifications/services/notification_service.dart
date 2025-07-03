import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/config/app_config.dart';
import '../../../core/routes/app_routes.dart';
import '../models/notification_model.dart';

class NotificationService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/notifications';
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Inicializa o serviço de notificações
  static Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Manipula o toque em uma notificação
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final data = json.decode(response.payload!);
      final String type = data['type'] ?? '';
      final String id = data['id'] ?? '';

      // Navegação baseada no tipo de notificação
      final context = _getGlobalContext();
      if (context == null) return;

      _navigateBasedOnType(context, type, id);
    } catch (e) {
      // Fallback para a tela de notificações em caso de erro
      final context = _getGlobalContext();
      if (context != null) {
        Navigator.of(context).pushNamed('/notifications');
      }
    }
  }

  /// Busca todas as notificações do usuário
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao obter notificações: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return _getMockNotifications();
    }
  }

  /// Marca uma notificação como lida
  static Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationModel.fromJson(data);
      } else {
        throw Exception(
            'Falha ao marcar notificação como lida: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      return NotificationModel(
        id: notificationId,
        title: 'Notificação',
        message: 'Conteúdo da notificação',
        type: NotificationType.system,
        createdAt: DateTime.now(),
        isRead: true,
      );
    }
  }

  /// Exibe uma notificação local
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    required String type,
    required String id,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'agenda_facil_channel',
      'Notificações AgendaFácil',
      channelDescription: 'Canal para notificações do AgendaFácil',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Gera payload com informações para navegação
    final String notificationPayload = payload ??
        json.encode({
          'type': type,
          'id': id,
        });

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: notificationPayload,
    );
  }

  /// Obtém o contexto global para navegação
  static BuildContext? _getGlobalContext() {
    return WidgetsBinding.instance.platformDispatcher.views.first.context;
  }

  /// Navega para a tela apropriada com base no tipo de notificação
  static void _navigateBasedOnType(
      BuildContext context, String type, String id) {
    switch (type) {
      case 'appointment':
        Navigator.of(context).pushNamed('/appointments/$id');
        break;
      case 'payment':
        Navigator.of(context).pushNamed(AppRoutes.pixHistory);
        break;
      case 'system':
      case 'marketing':
        Navigator.of(context).pushNamed('/notifications');
        break;
      default:
        Navigator.of(context).pushNamed('/notifications');
    }
  }

  /// Gera dados simulados para desenvolvimento
  static List<NotificationModel> _getMockNotifications() {
    return [
      NotificationModel(
        id: 'notif-1',
        title: 'Novo agendamento',
        message: 'Você tem um novo agendamento para amanhã às 14:00',
        type: NotificationType.appointment,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        data: <String, dynamic>{
          'appointmentId': 'appt-123',
          'clientName': 'João Silva',
          'serviceType': 'Corte de Cabelo',
        },
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Lembrete',
        message: 'Não esqueça do seu agendamento hoje às 16:30',
        type: NotificationType.reminder,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Atualização do sistema',
        message: 'O sistema foi atualizado com novos recursos',
        type: NotificationType.system,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        id: 'notif-4',
        title: 'Promoção de Julho',
        message: 'Aproveite 20% de desconto em todos os serviços',
        type: NotificationType.marketing,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      NotificationModel(
        id: 'notif-5',
        title: 'Pagamento recebido',
        message: 'Você recebeu um pagamento de R\$ 50,00',
        type: NotificationType.payment,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        data: <String, dynamic>{'amount': 50.0, 'paymentMethod': 'PIX'},
      ),
    ];
  }
}

extension on FlutterView {
  BuildContext? get context => null;
}
