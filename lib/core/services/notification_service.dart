import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleAppointmentReminder(Appointment appointment) async {
    // Lembrete 1 hora antes
    final reminderTime = appointment.dateTime.subtract(const Duration(hours: 1));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        appointment.id.hashCode,
        'Lembrete de Agendamento',
        'Você tem um agendamento em 1 hora: ${appointment.service} com ${appointment.clientName}',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminders',
            'Lembretes de Agendamento',
            channelDescription: 'Notificações de lembretes de agendamentos',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // Lembrete no dia anterior
    final dayBeforeReminder = DateTime(
      appointment.dateTime.year,
      appointment.dateTime.month,
      appointment.dateTime.day - 1,
      20, // 20:00
    );

    if (dayBeforeReminder.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        appointment.id.hashCode + 1,
        'Agendamento Amanhã',
        'Você tem um agendamento amanhã às ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} - ${appointment.service}',
        tz.TZDateTime.from(dayBeforeReminder, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminders',
            'Lembretes de Agendamento',
            channelDescription: 'Notificações de lembretes de agendamentos',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAppointmentNotification(String appointmentId) async {
    await _notifications.cancel(appointmentId.hashCode);
    await _notifications.cancel(appointmentId.hashCode + 1);
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Notificações Instantâneas',
          channelDescription: 'Notificações imediatas do sistema',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleClientConfirmationReminder(Appointment appointment) async {
    // Lembrete para cliente confirmar 24h antes
    final confirmationTime = appointment.dateTime.subtract(const Duration(hours: 24));
    
    if (confirmationTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        appointment.id.hashCode + 2,
        'Confirmação Necessária',
        'Cliente ${appointment.clientName} precisa confirmar agendamento de ${appointment.service}',
        tz.TZDateTime.from(confirmationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'client_confirmations',
            'Confirmações de Cliente',
            channelDescription: 'Lembretes para confirmação de clientes',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}