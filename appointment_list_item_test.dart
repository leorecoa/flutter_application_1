import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/presentation/controllers/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/presentation/widgets/appointment_list_item.dart';
import 'package:mocktail/mocktail.dart';

// 1. Create a Mock class for the controller using mocktail.
// This class can mimic the real controller's behavior in a controlled way for our tests.
// It extends StateNotifier and implements the real controller to satisfy the type system.
class MockAppointmentScreenController extends StateNotifier<AsyncValue<void>>
    with Mock
    implements AppointmentScreenController {}

void main() {
  // 2. Declare variables that will be used across tests.
  // 'late' means they will be initialized before they are used.
  late MockAppointmentScreenController mockController;
  late Appointment testAppointment;

  // The setUp function runs before each test, ensuring a clean state.
  setUp(() {
    mockController = MockAppointmentScreenController();
    testAppointment = Appointment(
      id: '1',
      clientName: 'Jane Doe',
      serviceName: 'Manicure',
      dateTime: DateTime(2023, 10, 27, 14, 30),
      status: AppointmentStatus.scheduled,
    );
  });

  // 3. Create a helper function to build our widget for testing.
  // This avoids boilerplate code in each test.
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        // We override the real provider to return our mock controller instance.
        // This is the core of testing with Riverpod.
        appointmentScreenControllerProvider.overrideWithValue(mockController),
      ],
      // We wrap with MaterialApp and Scaffold to provide a valid context
      // for dialogs and snackbars.
      child: MaterialApp(
        home: Scaffold(body: AppointmentListItem(appointment: testAppointment)),
      ),
    );
  }

  group('AppointmentListItem', () {
    testWidgets('renders correctly with initial data', (tester) async {
      // Arrange: Build the widget.
      await tester.pumpWidget(createTestWidget());

      // Assert: Check if the appointment's details are displayed.
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.textContaining('Manicure'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets(
      'tapping delete button calls deleteAppointment on the controller',
      (tester) async {
        // Arrange:
        // Set up the mock to expect a call to deleteAppointment.
        // We return a successful Future to simulate a completed network call.
        when(
          () => mockController.deleteAppointment(any()),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());

        // Act: Find the delete button and tap it.
        await tester.tap(find.byIcon(Icons.delete));
        // pump() advances the frame after the tap.
        await tester.pump();

        // Assert:
        // Verify that deleteAppointment was called exactly once with the correct appointment.
        verify(
          () => mockController.deleteAppointment(testAppointment),
        ).called(1);
      },
    );

    testWidgets('delete button is disabled when controller state is loading', (
      tester,
    ) async {
      // Arrange:
      // We need to provide a controller that is already in the loading state.
      // We can't set the state on the mock directly, so we create a new one
      // and initialize it with the desired state.
      final loadingController = MockAppointmentScreenController();
      when(() => loadingController.state).thenReturn(const AsyncLoading());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appointmentScreenControllerProvider.overrideWithValue(
              loadingController,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AppointmentListItem(appointment: testAppointment),
            ),
          ),
        ),
      );

      // Assert:
      // Find the IconButton and check that its onPressed callback is null,
      // which means it's disabled.
      final deleteButton = tester.widget<IconButton>(find.byIcon(Icons.delete));
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets(
      'shows loading dialog and success snackbar on successful deletion',
      (tester) async {
        // Arrange:
        // When deleteAppointment is called, we'll use thenAnswer to manually
        // control the state changes, simulating the real controller's behavior.
        when(() => mockController.deleteAppointment(any())).thenAnswer((
          _,
        ) async {
          // The widget listens to the state, so we update it here.
          mockController.state = const AsyncLoading();
          // Simulate a network delay
          await Future.delayed(const Duration(milliseconds: 100));
          mockController.state = const AsyncData(null);
        });

        await tester.pumpWidget(createTestWidget());

        // Act: Tap the delete button.
        await tester.tap(find.byIcon(Icons.delete));

        // Assert (Loading):
        // The first pump triggers the state change to AsyncLoading.
        await tester.pump();
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: 'A loading dialog should be shown',
        );

        // Assert (Success):
        // Pump the remaining time of our simulated delay.
        await tester.pump(const Duration(milliseconds: 100));
        // The dialog is popped and the success snackbar is shown.
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Ação concluída com sucesso!'), findsOneWidget);
      },
    );
  });
}
