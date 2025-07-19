import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/models/notification_action_model.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/appointments/services/appointments_service_v2.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/screens/appointments_screen.dart';

import 'notification_flow_test.mocks.dart';

@GenerateMocks([
  NotificationService,
  AppointmentsServiceV2,
])
void main() {
  late MockNotificationService mockNotificationService;
  late MockAppointmentsServiceV2 mockAppointmentsService;
  late StreamController<NotificationAction> actionStreamController;
  late ProviderContainer container;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockAppointmentsService = MockAppointmentsServiceV2();
    actionStreamController = StreamController<NotificationAction>.broadcast();

    // Configurar o mock para retornar o stream controlado
    when(mockNotificationService.actionStream).thenAnswer(
      (_) => actionStreamController.stream,
    );

    // Configurar o mock para retornar uma lista de agendamentos
    when(mockAppointmentsService.getAppointmentsList())
        .thenAnswer((_) async => [
              Appointment(
                id: '1',
                clientName: 'Client 1',
                clientPhone: '123456789',
                service: 'Service 1',
                dateTime: DateTime.now().add(const Duration(days: 1)),
                price: 100.0,
                status: AppointmentStatus.scheduled,
              ),
            ]);

    // Criar um ProviderContainer de teste
    container = ProviderContainer(
      overrides: [
        // Sobrescrever os providers com os mocks
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        appointmentsServiceProvider.overrideWithValue(mockAppointmentsService),
      ],
    );
  });

  tearDown(() {
    actionStreamController.close();
    container.dispose();
  });

  testWidgets(
      'Full notification flow should update UI when action is processed',
      (WidgetTester tester) async {
    // Arrange - Construir a tela de agendamentos
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AppointmentsScreen(),
        ),
      ),
    );

    // Aguardar o carregamento inicial
    await tester.pumpAndSettle();

    // Verificar que a lista de agendamentos foi carregada
    verify(mockAppointmentsService.getAppointmentsList()).called(1);

    // Act - Simular uma ação de confirmação
    actionStreamController.add(
      const NotificationAction(
        appointmentId: '1',
        actionType: NotificationService.confirmAction,
      ),
    );

    // Aguardar o processamento da ação
    await tester.pumpAndSettle();

    // Assert - Verificar que a lista de agendamentos foi recarregada
    verify(mockAppointmentsService.getAppointmentsList()).called(2);

    // Verificar que um SnackBar foi exibido
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Agendamento confirmado com sucesso!'), findsOneWidget);
  });
}
