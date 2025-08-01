import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/features/appointments/domain/appointment_repository.dart';
import 'package:flutter_application_1/features/appointments/domain/usecases/additional_appointment_usecases.dart';

import 'additional_appointment_usecases_test.mocks.dart';

@GenerateMocks([AppointmentRepository])
void main() {
  late MockAppointmentRepository mockRepository;
  late GetAppointmentsUseCase getAppointmentsUseCase;
  late UpdateAppointmentUseCase updateAppointmentUseCase;
  late ExportAppointmentsUseCase exportAppointmentsUseCase;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    getAppointmentsUseCase = GetAppointmentsUseCase(mockRepository);
    updateAppointmentUseCase = UpdateAppointmentUseCase(mockRepository);
    exportAppointmentsUseCase = ExportAppointmentsUseCase(mockRepository);
  });

  group('GetAppointmentsUseCase', () {
    test('should get appointments with filters', () async {
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
      ];

      final filters = {'status': 'scheduled'};

      when(
        mockRepository.getPaginatedAppointments(
          page: 1,
          pageSize: 20,
          filters: filters,
        ),
      ).thenAnswer((_) async => appointments);

      // Act
      final result = await getAppointmentsUseCase.execute(
        page: 1,
        pageSize: 20,
        filters: filters,
      );

      // Assert
      expect(result, equals(appointments));
      verify(
        mockRepository.getPaginatedAppointments(
          page: 1,
          pageSize: 20,
          filters: filters,
        ),
      ).called(1);
    });

    test('should throw UseCaseException when repository fails', () async {
      // Arrange
      when(
        mockRepository.getPaginatedAppointments(
          page: 1,
          pageSize: 20,
          filters: null,
        ),
      ).thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(
        () => getAppointmentsUseCase.execute(page: 1, pageSize: 20),
        throwsA(isA<UseCaseException>()),
      );
    });
  });

  group('UpdateAppointmentUseCase', () {
    test('should update appointment', () async {
      // Arrange
      final appointment = Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'serv1',
        dateTime: DateTime.now().add(const Duration(days: 1)), // Futuro
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        status: AppointmentStatus.scheduled,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockRepository.updateAppointment(appointment),
      ).thenAnswer((_) async => appointment);

      // Act
      final result = await updateAppointmentUseCase.execute(appointment);

      // Assert
      expect(result, equals(appointment));
      verify(mockRepository.updateAppointment(appointment)).called(1);
    });

    test('should throw UseCaseException when validation fails', () async {
      // Arrange
      final appointment = Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'serv1',
        dateTime: DateTime.now().subtract(const Duration(days: 1)), // Passado
        clientName: 'Test Client',
        clientPhone: '123456789',
        service: 'Test Service',
        price: 100.0,
        status: AppointmentStatus.scheduled,
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => updateAppointmentUseCase.execute(appointment),
        throwsA(isA<UseCaseException>()),
      );
    });
  });

  group('ExportAppointmentsUseCase', () {
    test('should export appointments as CSV', () async {
      // Arrange
      final appointments = [
        Appointment(
          id: '1',
          professionalId: 'prof1',
          serviceId: 'serv1',
          dateTime: DateTime(2023, 7, 15, 10, 30),
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
        mockRepository.getAllAppointments(),
      ).thenAnswer((_) async => appointments);

      // Act
      final result = await exportAppointmentsUseCase.execute();

      // Assert
      expect(
        result,
        contains('ID,Cliente,Serviço,Data,Hora,Status,Valor,Confirmado'),
      );
      expect(
        result,
        contains(
          '1,Test Client,Test Service,15/07/2023,10:30,scheduled,100,00,Não',
        ),
      );
      verify(mockRepository.getAllAppointments()).called(1);
    });

    test('should throw UseCaseException for unsupported format', () async {
      // Arrange
      when(mockRepository.getAllAppointments()).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => exportAppointmentsUseCase.execute(format: 'pdf'),
        throwsA(isA<UseCaseException>()),
      );
    });
  });
}
