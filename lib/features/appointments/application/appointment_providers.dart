import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/core/providers/firebase_providers.dart';
import 'package:flutter_application_1/core/providers/tenant_provider.dart';
import 'package:flutter_application_1/features/appointments/data/appointment_repository_impl.dart';
import 'package:flutter_application_1/features/appointments/domain/appointment_repository.dart';

/// Provider para a implementação do repositório de agendamentos.
final appointmentRepositoryProvider = Provider<IAppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(ref.watch(firestoreProvider));
});

/// Provider que busca a lista de agendamentos para o tenant ativo.
///
/// Ele observa o [tenantProvider]. Se o tenantId mudar, ele será
/// re-executado automaticamente, buscando os dados do novo tenant.
final appointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final tenantId = ref.watch(tenantProvider);
  final appointmentRepository = ref.watch(appointmentRepositoryProvider);

  // Se nenhum tenant estiver selecionado, retorna uma lista vazia.
  // A UI deve tratar este caso e talvez mostrar uma mensagem para o usuário.
  if (tenantId == null) {
    return [];
  }

  // Busca os agendamentos do tenant ativo.
  final appointments =
      await appointmentRepository.getAppointments(tenantId: tenantId);
  return appointments;
});
