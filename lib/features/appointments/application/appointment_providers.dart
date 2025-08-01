import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/appointment_repository_local.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/usecases/get_appointments_usecase.dart';
import '../../../core/tenant/tenant_context.dart';

/// Provider para o repositório de agendamentos (implementação local)
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return LocalAppointmentRepository();
});

/// Provider para o contexto do tenant (simulado)
final tenantContextProvider = Provider<TenantContext>((ref) {
  return LocalTenantContext();
});

/// Provider para o caso de uso de buscar agendamentos
final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  final tenantContext = ref.watch(tenantContextProvider);
  return GetAppointmentsUseCase(repository, tenantContext);
});

/// Provider para todos os agendamentos (sem filtros)
final allAppointmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(appointmentRepositoryProvider);
  return await repository.getAppointments(
    page: 1,
    pageSize: 1000, // Buscar um número grande para o mês todo
  );
});

/// Provider para agendamentos filtrados por data
final appointmentsByDateProvider =
    FutureProvider.family<List<dynamic>, DateTime>((ref, date) async {
      final repository =
          ref.read(appointmentRepositoryProvider) as LocalAppointmentRepository;
      return await repository.getAppointmentsByDate(date);
    });

/// Provider para agendamentos com filtros
final filteredAppointmentsProvider =
    FutureProvider.family<List<dynamic>, Map<String, dynamic>>((
      ref,
      filters,
    ) async {
      final repository = ref.read(appointmentRepositoryProvider);
      return await repository.getAppointments(
        page: 1,
        pageSize: 100,
        filters: filters,
      );
    });

/// Provider para estatísticas de agendamentos
final appointmentStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final appointments = await ref.read(allAppointmentsProvider.future);

  final total = appointments.length;
  final confirmed = appointments.where((a) => a.status == 'confirmed').length;
  final pending = appointments.where((a) => a.status == 'pending').length;
  final cancelled = appointments.where((a) => a.status == 'cancelled').length;

  return {
    'total': total,
    'confirmed': confirmed,
    'pending': pending,
    'cancelled': cancelled,
  };
});

/// Provider para agendamentos do dia
final todayAppointmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final today = DateTime.now();
  return await ref.read(appointmentsByDateProvider(today).future);
});

/// Provider para agendamentos da semana
final weekAppointmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));

  final repository =
      ref.read(appointmentRepositoryProvider) as LocalAppointmentRepository;
  final allAppointments = await repository.getAppointments(
    page: 1,
    pageSize: 1000,
  );

  return allAppointments.where((appointment) {
    final appointmentDate = appointment.dateTime;
    return appointmentDate.isAfter(weekStart) &&
        appointmentDate.isBefore(weekEnd);
  }).toList();
});

/// Provider para agendamentos do mês
final monthAppointmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0);

  final repository =
      ref.read(appointmentRepositoryProvider) as LocalAppointmentRepository;
  final allAppointments = await repository.getAppointments(
    page: 1,
    pageSize: 1000,
  );

  return allAppointments.where((appointment) {
    final appointmentDate = appointment.dateTime;
    return appointmentDate.isAfter(monthStart) &&
        appointmentDate.isBefore(monthEnd);
  }).toList();
});

/// Provider para inicializar dados de exemplo
final initializeSampleDataProvider = FutureProvider<void>((ref) async {
  final repository =
      ref.read(appointmentRepositoryProvider) as LocalAppointmentRepository;
  await repository.initializeSampleData();
});
