import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/features/appointments/domain/appointment_repository.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/features/appointments/domain/usecases/appointment_usecases.dart';

import 'appointment_usecases_test.mocks.dart';

@GenerateMocks([AppointmentRepository, NotificationService])
void main() {
  late MockAppointmentRepository mockRepository;
  late MockNotificationService mockNotificationService;
  late CreateRecurringAppointmentsUseCase createUseCase;
  late DeleteAppointmentUseCase deleteUseCase;
  late UpdateAppointmentStatusUseCase updateStatusUseCase;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    mockNotificationService = MockNotificationService();
    createUseCase = CreateRecurringAppointmentsUseCase(
      mockRepository,
      mockNotificationService,
    );
    deleteUseCase = DeleteAppointmentUseCase(
      mockRepository,
      mockNotificationService,
    );
    updateStatusUseCase = UpdateAppointmentStatusUseCase(mockRepository);
  });

  group('CreateRecurringAppointmentsUseCase', () {
    test('should create appointments and schedule notifications', () async {
      // Arrange
      final appointments = [
        Appointment(
          id: '1',
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

      when(
        mockRepository.createBatchAppointments(appointments),
      ).thenAnswer((_) async => appointments);

      when(
        mockNotificationService.scheduleAppointmentReminders(any),
      ).thenAnswer((_) async {
        return null;
      });

      // Act
      final result = await createUseCase.execute(appointments);

      // Assert
      expect(result, equals(appointments));
      verify(mockRepository.createBatchAppointments(appointments)).called(1);
      verify(
        mockNotificationService.scheduleAppointmentReminders(any),
      ).called(1);
    });

    test('should throw UseCaseException when validation fails', () async {
      // Arrange
      final appointments = [
        Appointment(
          id: '1',
          professionalId: 'prof1',
          serviceId: 'serv1',
          dateTime: DateTime.now().subtract(
            const Duration(days: 1),
          ), // Data no passado
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

      // Act & Assert
      expect(
        () => createUseCase.execute(appointments),
        throwsA(isA<UseCaseException>()),
      );
    });
  });

  group('DeleteAppointmentUseCase', () {
    test('should delete appointment and cancel notifications', () async {
      // Arrange
      const appointmentId = '1';

      when(mockRepository.deleteAppointment(appointmentId)).thenAnswer((
        _,
      ) async {
        return null;
      });

      when(
        mockNotificationService.cancelAppointmentNotifications(appointmentId),
      ).thenAnswer((_) async {
        return null;
      });

      // Act
      await deleteUseCase.execute(appointmentId);

      // Assert
      verify(mockRepository.deleteAppointment(appointmentId)).called(1);
      verify(
        mockNotificationService.cancelAppointmentNotifications(appointmentId),
      ).called(1);
    });

    test('should throw UseCaseException when repository fails', () async {
      // Arrange
      const appointmentId = '1';

      when(
        mockRepository.deleteAppointment(appointmentId),
      ).thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(
        () => deleteUseCase.execute(appointmentId),
        throwsA(isA<UseCaseException>()),
      );
    });
  });

  group('UpdateAppointmentStatusUseCase', () {
    test('should update appointment status', () async {
      // Arrange
      const appointmentId = '1';
      const status = AppointmentStatus.confirmed;
      final updatedAppointment = Appointment(
        id: appointmentId,
        professionalId: 'prof1',
        serviceId: 'serv1',
        dateTime: DateTime.now(),
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        status: status,
        confirmedByClient: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockRepository.updateAppointmentStatus(appointmentId, status),
      ).thenAnswer((_) async => updatedAppointment);

      // Act
      final result = await updateStatusUseCase.execute(appointmentId, status);

      // Assert
      expect(result, equals(updatedAppointment));
      verify(
        mockRepository.updateAppointmentStatus(appointmentId, status),
      ).called(1);
    });

    test('should throw UseCaseException when repository fails', () async {
      // Arrange
      const appointmentId = '1';
      const status = AppointmentStatus.confirmed;

      when(
        mockRepository.updateAppointmentStatus(appointmentId, status),
      ).thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(
        () => updateStatusUseCase.execute(appointmentId, status),
        throwsA(isA<UseCaseException>()),
      );
    });
  });
}
