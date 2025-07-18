import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/appointment_model.dart';
import '../models/notification_action_model.dart';
import '../routes/app_router.dart';
import '../../features/notifications/services/notification_history_service.dart';

// Provider para acesso global ao serviço de notificações
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Ações para notificações
  static const String confirmAction = 'CONFIRM';
  static const String cancelAction = 'CANCEL';
  
  // Stream para comunicar ações de notificações
  final StreamController<NotificationAction> _actionStreamController = 
      StreamController<NotificationAction>.broadcast();
  Stream<NotificationAction> get actionStream => _actionStreamController.stream;

  NotificationService._();

  Future<void> init() async {
    if (_isInitialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    
    // Configurar ações para Android
    if (Platform.isAndroid) {
      await _setupNotificationActions();
    }

    // Configurações para Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    final List<DarwinNotificationCategory> darwinNotificationCategories = [
      DarwinNotificationCategory(
        'appointment',
        actions: [
          DarwinNotificationAction(
            confirmAction,
            'Confirmar',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction(
            cancelAction,
            'Cancelar',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
      ),
    ];
    
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {
        debugPrint('iOS notification: $id, $title, $body, $payload');
        return null;
      },
      notificationCategories: Set<DarwinNotificationCategory>.from(darwinNotificationCategories),
    );

    // Configurações gerais
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveLocalNotification,
    );

    _isInitialized = true;
  }
  
  Future<void> _setupNotificationActions() async {
    // Configurar ações para Android
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }
  
  void _onDidReceiveLocalNotification(NotificationResponse response) {
    debugPrint('Notificação clicada: ${response.payload}');
    
    if (response.payload != null) {
      // Verificar se é uma ação ou um clique normal
      if (response.actionId != null) {
        // É uma ação (confirmar ou cancelar)
        _actionStreamController.add(NotificationAction(
          appointmentId: response.payload!,
          actionType: response.actionId!,
        ));
      } else {
        // É um clique normal na notificação
        _navigateToAppointmentDetails(response.payload!);
      }
    }
  }
  
  void _navigateToAppointmentDetails(String appointmentId) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      // Navegar para a tela de detalhes do agendamento usando o ID
      GoRouter.of(context).go('/appointment-details/$appointmentId');
    } else {
      // Se não tiver contexto, usar deeplink
      final uri = Uri.parse('agendemais://appointment/$appointmentId');
      debugPrint('Tentando abrir deeplink: $uri');
      // Aqui você pode usar o pacote url_launcher para abrir o deeplink
      // url_launcher.launchUrl(uri);
    }
  }

  /// Gera um ID de notificação único e determinístico para o lembrete de 1 dia.
  int _getDayNotificationId(String appointmentId) {
    // Usar o hashCode de uma string modificada garante um ID diferente para cada tipo.
    return (appointmentId + "_day").hashCode;
  }

  /// Gera um ID de notificação único e determinístico para o lembrete de 1 hora.
  int _getHourNotificationId(String appointmentId) {
    return (appointmentId + "_hour").hashCode;
  }
  
  Future<void> scheduleAppointmentReminders(Appointment appointment) async {
    if (!_isInitialized) await init();

    // Cancelar notificações existentes para este agendamento
    await cancelAppointmentNotifications(appointment.id);
    
    final dayId = _getDayNotificationId(appointment.id);
    final hourId = _getHourNotificationId(appointment.id);

    // Agendar notificação para 1 dia antes
    await _scheduleNotification(
      id: dayId,
      title: 'Lembrete de Agendamento',
      body: 'Você tem ${appointment.service} amanhã às ${_formatTime(appointment.dateTime)}',
      scheduledDate: appointment.dateTime.subtract(const Duration(days: 1)),
      payload: appointment.id,
      showActions: false,
      groupKey: 'com.agendemais.appointment.reminders',
      groupAlertBehavior: GroupAlertBehavior.summary,
    );

    // Agendar notificação para 1 hora antes
    await _scheduleNotification(
      id: hourId,
      title: 'Agendamento em Breve',
      body: 'Seu agendamento de ${appointment.service} será em 1 hora',
      scheduledDate: appointment.dateTime.subtract(const Duration(hours: 1)),
      payload: appointment.id,
      showActions: true,
      groupKey: 'com.agendemais.appointment.reminders',
      groupAlertBehavior: GroupAlertBehavior.summary,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool showActions = false,
    String? groupKey,
    GroupAlertBehavior? groupAlertBehavior,
  }) async {
    // Salvar no histórico de notificações
    final historyService = NotificationHistoryService();
    await historyService.saveNotification(
      title: title,
      body: body,
      appointmentId: payload,
    );
    // Verificar se a data agendada já passou
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('Data de notificação no passado: ${scheduledDate.toString()}');
      return;
    }
    
    debugPrint('Agendando notificação ID: $id para: ${scheduledDate.toString()}');

    // Configurar detalhes da notificação com ou sem ações
    NotificationDetails notificationDetails;
    
    if (showActions) {
      // Configurar ações para Android e iOS
      notificationDetails = NotificationDetails(
        android: Platform.isAndroid ? AndroidNotificationDetails(
          'appointment_channel',
          'Agendamentos',
          channelDescription: 'Notificações de agendamentos',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.blue,
          groupKey: groupKey,
          groupAlertBehavior: groupAlertBehavior,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              confirmAction,
              'Confirmar',
              icon: DrawableResourceAndroidBitmap('ic_confirm'),
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              cancelAction,
              'Cancelar',
              icon: DrawableResourceAndroidBitmap('ic_cancel'),
              showsUserInterface: false,
            ),
          ],
        ) : null,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'appointment', // Associa com a categoria definida na inicialização
          threadIdentifier: groupKey, // Agrupa notificações no iOS
        ),
      );
    } else {
      // Notificação padrão sem ações
      notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_channel',
          'Agendamentos',
          channelDescription: 'Notificações de agendamentos',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.blue,
          groupKey: groupKey,
          groupAlertBehavior: groupAlertBehavior,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: groupKey, // Agrupa notificações no iOS
        ),
      );
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAppointmentNotifications(String appointmentId) async {
    if (!_isInitialized) await init();

    // Cancelar as duas notificações associadas ao agendamento
    final dayId = _getDayNotificationId(appointmentId);
    final hourId = _getHourNotificationId(appointmentId);
    
    await _notificationsPlugin.cancel(dayId);
    await _notificationsPlugin.cancel(hourId);
    
    debugPrint('Notificações canceladas para o agendamento $appointmentId');
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  void dispose() {
    _actionStreamController.close();
  }
}