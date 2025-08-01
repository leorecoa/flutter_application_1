import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/widgets/client_confirmation_widget.dart';

import 'client_confirmation_widget_test.mocks.dart';

@GenerateMocks([Function])
void main() {
  late Appointment testAppointment;
  late MockFunction mockOnConfirmationChanged;

  setUp(() {
    testAppointment = Appointment(
      id: 'test-id',
      professionalId: 'prof-1',
      serviceId: 'service-1',
      clientId: 'client-1',
      clientName: 'Test Client',
      clientPhone: '123456789',
      service: 'Test Service',
      price: 100.0,
      dateTime: DateTime(2023, 1, 1, 10),
      duration: 60,
      status: AppointmentStatus.scheduled,
      notes: 'Test notes',
    );

    mockOnConfirmationChanged = MockFunction();
  });

  testWidgets(
    'ClientConfirmationWidget displays correctly for scheduled appointment',
    (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ClientConfirmationWidget(
                appointment: testAppointment,
                onConfirmationChanged: (id, isConfirmed) {
                  mockOnConfirmationChanged(id, isConfirmed);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(
        find.text('O cliente confirmou este agendamento?'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    },
  );

  testWidgets(
    'ClientConfirmationWidget calls onConfirmationChanged with true when confirmed',
    (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ClientConfirmationWidget(
                appointment: testAppointment,
                onConfirmationChanged: (id, isConfirmed) {
                  mockOnConfirmationChanged(id, isConfirmed);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // Assert
      verify(mockOnConfirmationChanged(testAppointment.id, true)).called(1);
    },
  );

  testWidgets(
    'ClientConfirmationWidget calls onConfirmationChanged with false when cancelled',
    (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ClientConfirmationWidget(
                appointment: testAppointment,
                onConfirmationChanged: (id, isConfirmed) {
                  mockOnConfirmationChanged(id, isConfirmed);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Assert
      verify(mockOnConfirmationChanged(testAppointment.id, false)).called(1);
    },
  );

  testWidgets(
    'ClientConfirmationWidget does not display for completed appointments',
    (WidgetTester tester) async {
      // Arrange
      final completedAppointment = testAppointment.copyWith(
        status: AppointmentStatus.completed,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ClientConfirmationWidget(
                appointment: completedAppointment,
                onConfirmationChanged: (id, isConfirmed) {
                  mockOnConfirmationChanged(id, isConfirmed);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('O cliente confirmou este agendamento?'), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    },
  );

  testWidgets(
    'ClientConfirmationWidget does not display for cancelled appointments',
    (WidgetTester tester) async {
      // Arrange
      final cancelledAppointment = testAppointment.copyWith(
        status: AppointmentStatus.cancelled,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ClientConfirmationWidget(
                appointment: cancelledAppointment,
                onConfirmationChanged: (id, isConfirmed) {
                  mockOnConfirmationChanged(id, isConfirmed);
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('O cliente confirmou este agendamento?'), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    },
  );
}
