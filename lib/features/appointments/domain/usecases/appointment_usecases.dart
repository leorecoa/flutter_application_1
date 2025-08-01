import '../../../core/models/appointment_model.dart';

/// Interface para o caso de uso de criação de agendamentos
abstract class CreateAppointmentUseCase {
  Future<Appointment> execute(Appointment appointment);
}

/// Interface para o caso de uso de busca de agendamentos
abstract class GetAppointmentsUseCase {
  Future<List<Appointment>> execute({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  });
}

/// Interface para o caso de uso de atualização de agendamento
abstract class UpdateAppointmentUseCase {
  Future<Appointment> execute(Appointment appointment);
}

/// Interface para o caso de uso de exclusão de agendamento
abstract class DeleteAppointmentUseCase {
  Future<void> execute(String appointmentId);
}

/// Interface para o caso de uso de atualização de status de agendamento
abstract class UpdateAppointmentStatusUseCase {
  Future<void> execute(String appointmentId, AppointmentStatus status);
}

/// Interface para o caso de uso de criação de agendamentos recorrentes
abstract class CreateRecurringAppointmentsUseCase {
  Future<List<Appointment>> execute(List<Appointment> appointments);
}

/// Interface para o caso de uso de exportação de agendamentos
abstract class ExportAppointmentsUseCase {
  Future<String> execute({String format = 'csv'});
}

/// Implementação simplificada do caso de uso de criação de agendamento
class CreateAppointmentUseCaseImpl implements CreateAppointmentUseCase {
  @override
  Future<Appointment> execute(Appointment appointment) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 400));
    return appointment;
  }
}

/// Implementação simplificada do caso de uso de exportação de agendamentos
class ExportAppointmentsUseCaseImpl implements ExportAppointmentsUseCase {
  @override
  Future<String> execute({String format = 'csv'}) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 500));
    return 'id,cliente,data,hora,serviço\n1,João,2023-07-20,14:00,Corte\n2,Maria,2023-07-21,15:30,Manicure';
  }
}

/// Implementação simplificada do caso de uso de criação de agendamentos recorrentes
class CreateRecurringAppointmentsUseCaseImpl
    implements CreateRecurringAppointmentsUseCase {
  @override
  Future<List<Appointment>> execute(List<Appointment> appointments) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 500));
    return appointments;
  }
}

/// Implementação simplificada do caso de uso de exclusão de agendamento
class DeleteAppointmentUseCaseImpl implements DeleteAppointmentUseCase {
  @override
  Future<void> execute(String appointmentId) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Implementação simplificada do caso de uso de atualização de status de agendamento
class UpdateAppointmentStatusUseCaseImpl
    implements UpdateAppointmentStatusUseCase {
  @override
  Future<void> execute(String appointmentId, AppointmentStatus status) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Implementação simplificada do caso de uso de busca de agendamentos
class GetAppointmentsUseCaseImpl implements GetAppointmentsUseCase {
  @override
  Future<List<Appointment>> execute({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Appointment(
        id: '1',
        professionalId: 'prof1',
        serviceId: 'service1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        clientName: 'João Silva',
        clientPhone: '11999999999',
        serviceName: 'Corte de Cabelo',
        price: 50.0,
        duration: const Duration(minutes: 30),
        confirmedByClient: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: '2',
        professionalId: 'prof1',
        serviceId: 'service2',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        clientName: 'Maria Oliveira',
        clientPhone: '11888888888',
        serviceName: 'Manicure',
        price: 30.0,
        status: AppointmentStatus.confirmed,
        duration: const Duration(minutes: 60),
        confirmedByClient: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

/// Implementação simplificada do caso de uso de atualização de agendamento
class UpdateAppointmentUseCaseImpl implements UpdateAppointmentUseCase {
  @override
  Future<Appointment> execute(Appointment appointment) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 400));
    return appointment;
  }
}
