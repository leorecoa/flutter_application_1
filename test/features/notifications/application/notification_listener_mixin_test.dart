import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/notification_action_event.dart';
import 'package:flutter_application_1/core/models/notification_action_model.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/notifications/application/notification_listener_mixin.dart';

import 'notification_listener_mixin_test.mocks.dart';

@GenerateMocks([NotificationService])
void main() {
  late MockNotificationService mockNotificationService;
  late StreamController<NotificationAction> actionStreamController;
  late ProviderContainer container;

  setUp(() {
    mockNotificationService = MockNotificationService();
    actionStreamController = StreamController<NotificationAction>.broadcast();
    
    // Configurar o mock para retornar o stream controlado
    when(mockNotificationService.actionStream).thenAnswer(
      (_) => actionStreamController.stream,
    );
    
    // Criar um ProviderContainer de teste
    container = ProviderContainer(
      overrides: [
        // Sobrescrever o provider do serviço de notificações com o mock
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
  });

  tearDown(() {
    actionStreamController.close();
    container.dispose();
  });

  testWidgets('NotificationActionListener should handle notification actions', 
      (WidgetTester tester) async {
    // Arrange
    final testKey = GlobalKey<TestNotificationListenerState>();
    
    // Build our widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: TestNotificationListener(key: testKey),
        ),
      ),
    );
    
    // Verificar que o método _listenToNotificationActions foi chamado
    verify(mockNotificationService.actionStream).called(1);
    
    // Act - Simular uma ação de confirmação
    actionStreamController.add(
      NotificationAction(
        appointmentId: '123',
        actionType: NotificationService.confirmAction,
      ),
    );
    
    // Aguardar o processamento da ação
    await tester.pumpAndSettle();
    
    // Assert - Verificar que o método onNotificationActionProcessed foi chamado
    expect(testKey.currentState!.processedEvents, contains(NotificationActionEvent.confirmed));
    
    // Act - Simular uma ação de cancelamento
    actionStreamController.add(
      NotificationAction(
        appointmentId: '123',
        actionType: NotificationService.cancelAction,
      ),
    );
    
    // Aguardar o processamento da ação
    await tester.pumpAndSettle();
    
    // Assert - Verificar que o método onNotificationActionProcessed foi chamado novamente
    expect(testKey.currentState!.processedEvents, contains(NotificationActionEvent.cancelled));
  });
}

// Widget de teste que implementa o mixin NotificationActionListener
class TestNotificationListener extends ConsumerStatefulWidget {
  const TestNotificationListener({Key? key}) : super(key: key);

  @override
  TestNotificationListenerState createState() => TestNotificationListenerState();
}

class TestNotificationListenerState extends ConsumerState<TestNotificationListener>
    with NotificationActionListener {
  final List<NotificationActionEvent> processedEvents = [];

  @override
  void onNotificationActionProcessed(NotificationActionEvent event) {
    processedEvents.add(event);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Widget'),
      ),
    );
  }
}