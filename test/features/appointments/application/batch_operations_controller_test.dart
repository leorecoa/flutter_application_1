import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/services/appointments/i_appointments_service.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/appointments/application/batch_operations_controller.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/application/paginated_appointments_notifier.dart';

import 'batch_operations_controller_test.mocks.dart';

@GenerateMocks([
  IAppointmentsService,
  NotificationService,
  PaginatedAppointmentsNotifier,
  ProviderContainer,
])
void main() {
  late MockIAppointmentsService mockAppointmentsService;
  late MockNotificationService mockNotificationService;
  late MockProviderContainer mockContainer;
  late BatchOperationsController controller;
  late List<Appointment> testAppointments;

  setUp(() {
    mockAppointmentsService = MockIAppointmentsService();
    mockNotificationService = MockNotificationService();
    mockContainer = MockProviderContainer();

    // Mock read function
    mockRead<T>(provider) {
      if (provider == paginatedAppointmentsProvider.notifier) {
        return MockPaginatedAppointmentsNotifier();
      }
      if (provider == allAppointmentsProvider.notifier) {
        return MockProviderContainer();
      }
      throw UnimplementedError('Provider not mocked');
    }

    controller = BatchOperationsController(
      mockAppointmentsService,
      mockNotificationService,
      mockRead,
    );

    // Create test appointments
    testAppointments = [
      Appointment(
        id: 'test-1',
        professionalId: 'prof-1',
        serviceId: 'service-1',
        clientId: 'client-1',
        clientName: 'Test Client 1',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        dateTime: DateTime(2023, 1, 1, 10),
        duration: 60,
        status: AppointmentStatus.scheduled,
        notes: 'Test notes',
      ),
      Appointment(
        id: 'test-2',
        professionalId: 'prof-1',
        serviceId: 'service-1',
        clientId: 'client-2',
        clientName: 'Test Client 2',
        clientPhone: '987654321',
        service: 'Test Service',
        price: 100.0,
        dateTime: DateTime(2023, 1, 2, 10),
        duration: 60,
        status: AppointmentStatus.scheduled,
        notes: 'Test notes',
      ),
    ];
  });

  group('cancelAppointments', () {
    test('should cancel all appointments successfully', () async {
      // Arrange
      when(
        mockAppointmentsService.updateAppointmentStatus(
          any,
          AppointmentStatus.cancelled,
        ),
      ).thenAnswer((_) async => {'success': true});

      // Act
      final result = await controller.cancelAppointments(testAppointments);

      // Assert
      expect(result.successCount, 2);
      expect(result.failureCount, 0);
      expect(result.errors, isEmpty);

      verify(
        mockAppointmentsService.updateAppointmentStatus(
          'test-1',
          AppointmentStatus.cancelled,
        ),
      ).called(1);

      verify(
        mockAppointmentsService.updateAppointmentStatus(
          'test-2',
          AppointmentStatus.cancelled,
        ),
      ).called(1);

      verify(
        mockNotificationService.cancelAppointmentNotifications('test-1'),
      ).called(1);
      verify(
        mockNotificationService.cancelAppointmentNotifications('test-2'),
      ).called(1);
    });

    test(
      'should handle partial failures when cancelling appointments',
      () async {
        // Arrange
        when(
          mockAppointmentsService.updateAppointmentStatus(
            'test-1',
            AppointmentStatus.cancelled,
          ),
        ).thenAnswer((_) async => {'success': true});

        when(
          mockAppointmentsService.updateAppointmentStatus(
            'test-2',
            AppointmentStatus.cancelled,
          ),
        ).thenThrow(Exception('API Error'));

        // Act
        final result = await controller.cancelAppointments(testAppointments);

        // Assert
        expect(result.successCount, 1);
        expect(result.failureCount, 1);
        expect(result.errors.length, 1);
        expect(result.errors[0], contains('Test Client 2'));

        verify(
          mockNotificationService.cancelAppointmentNotifications('test-1'),
        ).called(1);
        verifyNever(
          mockNotificationService.cancelAppointmentNotifications('test-2'),
        );
      },
    );
  });

  group('confirmAppointments', () {
    test('should confirm all appointments successfully', () async {
      // Arrange
      when(
        mockAppointmentsService.updateAppointmentStatus(
          any,
          AppointmentStatus.confirmed,
        ),
      ).thenAnswer((_) async => {'success': true});

      // Act
      final result = await controller.confirmAppointments(testAppointments);

      // Assert
      expect(result.successCount, 2);
      expect(result.failureCount, 0);
      expect(result.errors, isEmpty);

      verify(
        mockAppointmentsService.updateAppointmentStatus(
          'test-1',
          AppointmentStatus.confirmed,
        ),
      ).called(1);

      verify(
        mockAppointmentsService.updateAppointmentStatus(
          'test-2',
          AppointmentStatus.confirmed,
        ),
      ).called(1);
    });

    test(
      'should handle partial failures when confirming appointments',
      () async {
        // Arrange
        when(
          mockAppointmentsService.updateAppointmentStatus(
            'test-1',
            AppointmentStatus.confirmed,
          ),
        ).thenAnswer((_) async => {'success': true});

        when(
          mockAppointmentsService.updateAppointmentStatus(
            'test-2',
            AppointmentStatus.confirmed,
          ),
        ).thenThrow(Exception('API Error'));

        // Act
        final result = await controller.confirmAppointments(testAppointments);

        // Assert
        expect(result.successCount, 1);
        expect(result.failureCount, 1);
        expect(result.errors.length, 1);
        expect(result.errors[0], contains('Test Client 2'));
      },
    );
  });
}
