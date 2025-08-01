import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/appointments/domain/appointment_repository.dart';
import 'package:flutter_application_1/features/appointments/services/appointments_service_v2.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/application/service_providers.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';

import 'appointment_screen_controller_test.mocks.dart';

@GenerateMocks([
  AppointmentsServiceV2, 
  NotificationService, 
  PaginatedAppointmentsNotifier
])
void main() {
  late MockAppointmentsServiceV2 mockAppointmentsService;
  late MockNotificationService mockNotificationService;
  late MockPaginatedAppointmentsNotifier mockPaginatedNotifier;
  late ProviderContainer container;
  late AppointmentScreenController controller;

  setUp(() {
    mockAppointmentsService = MockAppointmentsServiceV2();
    mockNotificationService = MockNotificationService();
    mockPaginatedNotifier = MockPaginatedAppointmentsNotifier();

    container = ProviderContainer(
      overrides: [
        appointmentsServiceV2Provider.overrideWithValue(mockAppointmentsService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        paginatedAppointmentsProvider.notifier.overrideWith((_) => mockPaginatedNotifier),
      ],
    );

    controller = AppointmentScreenController(container);
  });

  tearDown(() {
    container.dispose();
  });

  group('AppointmentScreenController', () {
    test('createRecurringAppointments should use batch operation', () async {
      // Arrange
      final appointments = [
        Appointment(
          id: '1',
          professionalId: 'prof1',
          serviceId: 'serv1',
          dateTime: DateTime.now(),
          clientName: 'Test Client',
          clientPhone: '123456789',
          service: 'Test Service',
          price: 100.0,
          status: AppointmentStatus.scheduled,
          confirmedByClient: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Appointment(
          id: '2',
          professionalId: 'prof1',
          serviceId: 'serv1',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          clientName: 'Test Client',
          clientPhone: '123456789',
          service: 'Test Service',
          price: 100.0,
          status: AppointmentStatus.scheduled,
          confirmedByClient: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockAppointmentsService.createBatchAppointments(appointments))
          .thenAnswer((_) async => appointments);
      
      when(mockNotificationService.scheduleAppointmentReminders(any))
          .thenAnswer((_) async {
            return null;
          });
      
      when(mockPaginatedNotifier.fetchFirstPage())
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await controller.createRecurringAppointments(appointments);

      // Assert
      verify(mockAppointmentsService.createBatchAppointments(appointments)).called(1);
      verify(mockNotificationService.scheduleAppointmentReminders(any)).called(2);
      verify(mockPaginatedNotifier.fetchFirstPage()).called(1);
    });

    test('deleteAppointment should call service and cancel notifications', () async {
      // Arrange
      final appointment = Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'serv1',
        dateTime: DateTime.now(),
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        status: AppointmentStatus.scheduled,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAppointmentsService.deleteAppointment(appointment.id))
          .thenAnswer((_) async {
            return null;
          });
      
      when(mockNotificationService.cancelAppointmentNotifications(appointment.id))
          .thenAnswer((_) async {
            return null;
          });
      
      when(mockPaginatedNotifier.fetchFirstPage())
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await controller.deleteAppointment(appointment);

      // Assert
      verify(mockAppointmentsService.deleteAppointment(appointment.id)).called(1);
      verify(mockNotificationService.cancelAppointmentNotifications(appointment.id)).called(1);
      verify(mockPaginatedNotifier.fetchFirstPage()).called(1);
    });

    test('updateAppointmentStatus should update status correctly', () async {
      // Arrange
      const appointmentId = '1';
      const isConfirmed = true;
      final expectedStatus = AppointmentStatus.confirmed;
      
      final updatedAppointment = Appointment(
        id: appointmentId,
        professionalId: 'prof1',
        serviceId: 'serv1',
        dateTime: DateTime.now(),
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        status: expectedStatus,
        confirmedByClient: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAppointmentsService.updateAppointmentStatus(appointmentId, expectedStatus))
          .thenAnswer((_) async => updatedAppointment);
      
      when(mockPaginatedNotifier.fetchFirstPage())
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await controller.updateAppointmentStatus(appointmentId, isConfirmed);

      // Assert
      verify(mockAppointmentsService.updateAppointmentStatus(appointmentId, expectedStatus)).called(1);
      verify(mockPaginatedNotifier.fetchFirstPage()).called(1);
    });
  });
}