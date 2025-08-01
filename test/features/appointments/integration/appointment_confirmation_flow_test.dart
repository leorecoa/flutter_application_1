import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/services/appointments/i_appointments_service.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/widgets/client_confirmation_widget.dart';

import 'appointment_confirmation_flow_test.mocks.dart';

@GenerateMocks([IAppointmentsService])
void main() {
  late MockIAppointmentsService mockAppointmentsService;
  late ProviderContainer container;
  late Appointment testAppointment;

  setUp(() {
    mockAppointmentsService = MockIAppointmentsService();

    container = ProviderContainer(
      overrides: [
        appointmentsServiceProvider.overrideWithValue(mockAppointmentsService),
      ],
    );

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
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('Appointment confirmation flow updates UI correctly', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      mockAppointmentsService.updateAppointmentStatus(
        testAppointment.id,
        AppointmentStatus.confirmed,
      ),
    ).thenAnswer((_) async => {'success': true});

    // Build our test widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ClientConfirmationWidget(
                      appointment: testAppointment,
                      onConfirmationChanged: (id, isConfirmed) {
                        container
                            .read(appointmentScreenControllerProvider.notifier)
                            .updateAppointmentStatus(id, isConfirmed);
                      },
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(
                          appointmentScreenControllerProvider,
                        );
                        return state.when(
                          data: (_) => const Text('Sucesso'),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => Text('Erro: $e'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('O cliente confirmou este agendamento?'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Sucesso'), findsOneWidget);

    // Act - Confirm appointment
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(); // Start loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1)); // Complete loading

    // Assert
    verify(
      mockAppointmentsService.updateAppointmentStatus(
        testAppointment.id,
        AppointmentStatus.confirmed,
      ),
    ).called(1);

    expect(find.text('Sucesso'), findsOneWidget);
  });

  testWidgets('Appointment cancellation flow handles errors correctly', (
    WidgetTester tester,
  ) async {
    // Arrange
    final error = Exception('API Error');
    when(
      mockAppointmentsService.updateAppointmentStatus(
        testAppointment.id,
        AppointmentStatus.cancelled,
      ),
    ).thenThrow(error);

    // Build our test widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ClientConfirmationWidget(
                      appointment: testAppointment,
                      onConfirmationChanged: (id, isConfirmed) {
                        container
                            .read(appointmentScreenControllerProvider.notifier)
                            .updateAppointmentStatus(id, isConfirmed);
                      },
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(
                          appointmentScreenControllerProvider,
                        );
                        return state.when(
                          data: (_) => const Text('Sucesso'),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => Text('Erro: $e'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('O cliente confirmou este agendamento?'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Sucesso'), findsOneWidget);

    // Act - Cancel appointment
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(); // Start loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1)); // Complete loading

    // Assert
    verify(
      mockAppointmentsService.updateAppointmentStatus(
        testAppointment.id,
        AppointmentStatus.cancelled,
      ),
    ).called(1);

    expect(find.text('Erro: Exception: API Error'), findsOneWidget);
  });
}
