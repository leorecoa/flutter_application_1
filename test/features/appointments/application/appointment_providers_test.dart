import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/services/appointments_service_v2.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';

import 'appointment_providers_test.mocks.dart';

@GenerateMocks([AppointmentsServiceV2])
void main() {
  late MockAppointmentsServiceV2 mockAppointmentsService;
  late ProviderContainer container;
  
  setUp(() {
    mockAppointmentsService = MockAppointmentsServiceV2();
    
    // Criar um ProviderContainer de teste
    container = ProviderContainer(
      overrides: [
        // Sobrescrever o provider do serviço de agendamentos com o mock
        appointmentsServiceProvider.overrideWithValue(mockAppointmentsService),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  group('appointmentsProvider', () {
    test('should return all appointments when date is null', () async {
      // Arrange
      final appointments = [
        Appointment(
          id: '1',
          clientName: 'Client 1',
          clientPhone: '123456789',
          service: 'Service 1',
          dateTime: DateTime(2023, 7, 1, 10, 0),
          price: 100.0,
          status: AppointmentStatus.scheduled,
        ),
        Appointment(
          id: '2',
          clientName: 'Client 2',
          clientPhone: '987654321',
          service: 'Service 2',
          dateTime: DateTime(2023, 7, 2, 14, 0),
          price: 150.0,
          status: AppointmentStatus.confirmed,
        ),
      ];
      
      when(mockAppointmentsService.getAppointmentsList())
          .thenAnswer((_) async => appointments);
      
      // Act
      final result = await container.read(appointmentsProvider(null).future);
      
      // Assert
      expect(result, appointments);
      verify(mockAppointmentsService.getAppointmentsList()).called(1);
    });
    
    test('should filter appointments by date', () async {
      // Arrange
      final date = DateTime(2023, 7, 1);
      final appointments = [
        Appointment(
          id: '1',
          clientName: 'Client 1',
          clientPhone: '123456789',
          service: 'Service 1',
          dateTime: DateTime(2023, 7, 1, 10, 0),
          price: 100.0,
          status: AppointmentStatus.scheduled,
        ),
        Appointment(
          id: '2',
          clientName: 'Client 2',
          clientPhone: '987654321',
          service: 'Service 2',
          dateTime: DateTime(2023, 7, 2, 14, 0),
          price: 150.0,
          status: AppointmentStatus.confirmed,
        ),
      ];
      
      when(mockAppointmentsService.getAppointmentsList())
          .thenAnswer((_) async => appointments);
      
      // Act
      final result = await container.read(appointmentsProvider(date).future);
      
      // Assert
      expect(result.length, 1);
      expect(result[0].id, '1');
      verify(mockAppointmentsService.getAppointmentsList()).called(1);
    });
    
    test('should return empty list when no appointments match the date', () async {
      // Arrange
      final date = DateTime(2023, 7, 3);
      final appointments = [
        Appointment(
          id: '1',
          clientName: 'Client 1',
          clientPhone: '123456789',
          service: 'Service 1',
          dateTime: DateTime(2023, 7, 1, 10, 0),
          price: 100.0,
          status: AppointmentStatus.scheduled,
        ),
        Appointment(
          id: '2',
          clientName: 'Client 2',
          clientPhone: '987654321',
          service: 'Service 2',
          dateTime: DateTime(2023, 7, 2, 14, 0),
          price: 150.0,
          status: AppointmentStatus.confirmed,
        ),
      ];
      
      when(mockAppointmentsService.getAppointmentsList())
          .thenAnswer((_) async => appointments);
      
      // Act
      final result = await container.read(appointmentsProvider(date).future);
      
      // Assert
      expect(result, isEmpty);
      verify(mockAppointmentsService.getAppointmentsList()).called(1);
    });
  });
}