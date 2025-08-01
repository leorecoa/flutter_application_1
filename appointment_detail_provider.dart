import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/data/repositories/appointment_repository_provider.dart';

final appointmentDetailProvider = FutureProvider.family<Appointment, String>((
  ref,
  appointmentId,
) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  // TODO: Substituir por um provider que forneça o ID do tenant logado
  const tenantId = 'mock-tenant-id';

  final appointment = await repository.getAppointmentById(
    tenantId: tenantId,
    appointmentId: appointmentId,
  );
  return appointment;
});
