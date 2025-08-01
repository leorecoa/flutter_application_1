import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/domain/usecases/update_appointment_usecase.dart';
import 'package:flutter_application_1/domain/usecases/update_appointment_status_usecase.dart';
import 'package:flutter_application_1/domain/usecases/get_appointments_usecase.dart';
import 'package:flutter_application_1/domain/usecases/delete_appointment_usecase.dart';
import 'package:flutter_application_1/domain/usecases/export_appointments_usecase.dart';
import 'package:flutter_application_1/domain/usecases/create_recurring_appointments_usecase.dart';
import 'appointment_providers.dart';

/// Provider para o caso de uso de atualização de agendamento
final updateAppointmentUseCaseProvider = Provider<UpdateAppointmentUseCase>(
  (ref) => UpdateAppointmentUseCase(
    ref.watch(appointmentRepositoryProvider),
  ),
);

/// Provider para o caso de uso de atualização de status de agendamento
final updateAppointmentStatusUseCaseProvider = Provider<UpdateAppointmentStatusUseCase>(
  (ref) => UpdateAppointmentStatusUseCase(
    ref.watch(appointmentRepositoryProvider),
  ),
);

/// Provider para o caso de uso de exportação de agendamentos
final exportAppointmentsUseCaseProvider = Provider<ExportAppointmentsUseCase>(
  (ref) => ExportAppointmentsUseCase(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(tenantContextProvider),
  ),
);

/// Provider para o caso de uso de criação de agendamentos recorrentes
final createRecurringAppointmentsUseCaseProvider = Provider<CreateRecurringAppointmentsUseCase>(
  (ref) => CreateRecurringAppointmentsUseCase(
    ref.watch(appointmentRepositoryProvider),
  ),
);

/// Provider para o caso de uso de exclusão de agendamento
final deleteAppointmentUseCaseProvider = Provider<DeleteAppointmentUseCase>(
  (ref) => DeleteAppointmentUseCase(
    ref.watch(appointmentRepositoryProvider),
  ),
);

/// Provider para o caso de uso de busca de agendamentos
final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>(
  (ref) => GetAppointmentsUseCase(
    ref.watch(appointmentRepositoryProvider),
    ref.watch(tenantContextProvider),
  ),
);