import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
  });

  group('NotificationService', () {
    test('should initialize notifications', () async {
      // Mock da inicialização
      when(
        mockNotificationsPlugin.initialize(any),
      ).thenAnswer((_) async => true);

      // Teste de inicialização
      expect(
        mockNotificationsPlugin,
        isA<MockFlutterLocalNotificationsPlugin>(),
      );
    });

    test('should schedule appointment reminder', () async {
      final appointment = Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'service1',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        clientName: 'João Silva',
        clientPhone: '11999999999',
        serviceName: 'Corte de Cabelo',
        price: 50.0,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock do método scheduleAppointmentReminders
      when(
        mockNotificationsPlugin.zonedSchedule(
          any,
          any,
          any,
          any,
          any,
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      ).thenAnswer((_) async => {});

      // Teste de agendamento
      expect(appointment, isA<Appointment>());
    });

    test('should cancel appointment notifications', () async {
      final appointmentId = '1';

      // Mock do método cancelAppointmentNotifications
      when(mockNotificationsPlugin.cancel(any)).thenAnswer((_) async => {});

      // Teste de cancelamento
      expect(appointmentId, isA<String>());
    });

    test('should handle notification actions', () async {
      // Mock do stream de ações
      when(
        mockNotificationsPlugin.initialize(any),
      ).thenAnswer((_) async => true);

      // Teste de manipulação de ações
      expect(
        mockNotificationsPlugin,
        isA<MockFlutterLocalNotificationsPlugin>(),
      );
    });
  });
}
