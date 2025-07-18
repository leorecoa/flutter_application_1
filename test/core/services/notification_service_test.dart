import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/models/notification_action_model.dart';
import 'package:flutter_application_1/features/appointments/services/appointments_service_v2.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AppointmentsServiceV2,
])
void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAppointmentsServiceV2 mockAppointmentsService;
  late ProviderContainer container;

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAppointmentsService = MockAppointmentsServiceV2();
    
    // Criar um ProviderContainer de teste
    container = ProviderContainer(
      overrides: [
        // Sobrescrever o provider do serviço de agendamentos com o mock
        appointmentsServiceProvider.overrideWithValue(mockAppointmentsService),
      ],
    );
    
    // Injetar o mock do plugin de notificações no serviço
    notificationService = NotificationService.instance;
    notificationService.setNotificationsPlugin(mockNotificationsPlugin);
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationService', () {
    test('init should initialize the plugin', () async {
      // Arrange
      when(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);

      // Act
      await notificationService.init();

      // Assert
      verify(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
    });

    test('scheduleAppointmentReminders should schedule two notifications', () async {
      // Arrange
      final appointment = Appointment(
        id: '123',
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        price: 100.0,
        status: AppointmentStatus.scheduled,
      );

      when(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      // Act
      await notificationService.scheduleAppointmentReminders(appointment);

      // Assert
      verify(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        payload: anyNamed('payload'),
      )).called(2); // Uma para o lembrete de 1 dia e outra para o de 1 hora
    });

    test('cancelAppointmentNotifications should cancel two notifications', () async {
      // Arrange
      const appointmentId = '123';
      when(mockNotificationsPlugin.cancel(any)).thenAnswer((_) async {});

      // Act
      await notificationService.cancelAppointmentNotifications(appointmentId);

      // Assert
      verify(mockNotificationsPlugin.cancel(any)).called(2); // Uma para cada tipo de notificação
    });

    test('actionStream should emit events when actions are processed', () async {
      // Arrange
      const appointmentId = '123';
      when(mockAppointmentsService.updateAppointmentStatus(
        appointmentId,
        'confirmado',
      )).thenAnswer((_) async => {'success': true});

      // Act & Assert
      expectLater(
        notificationService.actionStream,
        emits(predicate<NotificationAction>((action) => 
          action.appointmentId == appointmentId && 
          action.actionType == NotificationService.confirmAction
        )),
      );

      // Simular o processamento de uma ação de confirmação
      await notificationService.testHandleConfirmAction(appointmentId);
    });
  });
}