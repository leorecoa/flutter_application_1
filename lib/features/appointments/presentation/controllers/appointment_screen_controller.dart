import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/analytics/analytics_service.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/core/tenant/tenant_repository.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/domain/usecases/appointment_usecases.dart';
import 'package:flutter_application_1/features/appointments/domain/usecases/additional_appointment_usecases.dart';
import 'package:flutter_application_1/core/providers/app_providers.dart';
import 'package:flutter_application_1/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/presentation/providers/service_providers.dart';

/// Provider para o controller da tela de agendamentos.
final appointmentScreenControllerProvider =
    StateNotifierProvider.autoDispose<
      AppointmentScreenController,
      AsyncValue<void>
    >((ref) => AppointmentScreenController(ref));

/// Controller que gerencia a lógica de negócio da tela de agendamentos.
class AppointmentScreenController extends StateNotifier<AsyncValue<void>> {
  AppointmentScreenController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  /// Inicializa o contexto do tenant para o usuário atual.
  /// Este método deve ser chamado pela UI ao carregar a tela.
  Future<void> initTenantContext() async {
    state = const AsyncLoading();
    try {
      final tenantContext = _ref.read(tenantContextProvider);
      await tenantContext.initialize();
      Logger.info(
        'Contexto do tenant inicializado',
        context: {
          'tenantId': tenantContext.currentTenant?.id,
          'tenantName': tenantContext.currentTenant?.name,
        },
      );

      // Inicializa o analytics com o evento de sessão iniciada
      // Em desenvolvimento, isso será apenas registrado localmente
      final analytics = _ref.read(analyticsServiceProvider);
      await analytics.trackEvent(
        'session_started',
        parameters: {'screen': 'appointment_screen'},
      );
      state = const AsyncData(null);
    } catch (e, s) {
      Logger.error(
        'Erro ao inicializar contexto do tenant',
        error: e,
        stackTrace: s,
      );
      state = AsyncError(e, s);
    }
  }

  /// Exporta agendamentos para o formato especificado
  Future<String?> exportAppointments({String format = 'csv'}) async {
    state = const AsyncLoading();
    try {
      // Verifica acesso do tenant ao recurso de exportação
      final tenantRepo = _ref.read(tenantRepositoryProvider);
      final tenantContext = _ref.read(tenantContextProvider);
      final tenantId = tenantContext.currentTenant?.id;

      if (tenantId == null) {
        throw UnauthorizedException('Nenhum tenant ativo');
      }

      final hasAccess = await tenantRepo.checkTenantAccess(tenantId, 'export');
      if (!hasAccess) {
        throw UnauthorizedException(
          'Seu plano não permite exportação de dados',
        );
      }

      // Usa o caso de uso para exportar agendamentos
      final useCase = _ref.read(exportAppointmentsUseCaseProvider);
      final exportData = await useCase.execute(format: format);

      // Salva o arquivo exportado
      final storageService = _ref.read(storageServiceProvider);
      final fileName =
          'agendamentos_${DateTime.now().millisecondsSinceEpoch}.$format';
      final filePath = await storageService.saveToDownloads(
        fileName,
        exportData,
      );

      // Registra evento de analytics (apenas localmente em desenvolvimento)
      final analytics = _ref.read(analyticsServiceProvider);
      await analytics.trackEvent(
        'appointments_exported',
        parameters: {
          'format': format,
          'count': exportData.length,
          'filePath': filePath,
        },
      );

      Logger.info(
        'Agendamentos exportados',
        context: {'format': format, 'filePath': filePath},
      );

      state = const AsyncData(null);
      return filePath;
    } catch (e, s) {
      Logger.error('Erro ao exportar agendamentos', error: e, stackTrace: s);
      state = AsyncError(e, s);
      return null;
    }
  }

  /// Cria múltiplos agendamentos recorrentes de forma otimizada.
  Future<void> createRecurringAppointments(
    List<Appointment> appointments,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para criar agendamentos recorrentes
        final useCase = _ref.read(createRecurringAppointmentsUseCaseProvider);
        final createdAppointments = await useCase.execute(appointments);

        // Recarrega a lista de agendamentos uma única vez
        await _ref
            .read(paginatedAppointmentsProvider.notifier)
            .fetchFirstPage();

        // Registra evento de analytics
        Logger.info(
          'Agendamentos recorrentes criados',
          context: {
            'count': createdAppointments.length,
            'firstDate': createdAppointments.first.dateTime.toIso8601String(),
          },
        );
      } catch (e, s) {
        Logger.error(
          'Erro ao criar agendamentos recorrentes',
          error: e,
          stackTrace: s,
        );
        rethrow;
      }
    });
  }

  /// Exclui um agendamento e suas notificações.
  Future<void> deleteAppointment(Appointment appointment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para excluir agendamento
        final useCase = _ref.read(deleteAppointmentUseCaseProvider);
        await useCase.execute(appointment.id);

        // Recarrega a lista de agendamentos
        await _ref
            .read(paginatedAppointmentsProvider.notifier)
            .fetchFirstPage();

        // Registra evento de analytics
        Logger.info(
          'Agendamento excluído',
          context: {
            'appointmentId': appointment.id,
            'clientName': appointment.clientName,
          },
        );
      } catch (e, s) {
        Logger.error('Erro ao excluir agendamento', error: e, stackTrace: s);
        rethrow;
      }
    });
  }

  /// Atualiza o status de um agendamento (confirmado/cancelado).
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus newStatus,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para atualizar status
        final useCase = _ref.read(updateAppointmentStatusUseCaseProvider);
        await useCase.execute(appointmentId, newStatus.name);

        // Recarrega a lista de agendamentos
        await _ref
            .read(paginatedAppointmentsProvider.notifier)
            .fetchFirstPage();

        // Registra evento de analytics
        Logger.info(
          'Status de agendamento atualizado',
          context: {
            'appointmentId': appointmentId,
            'newStatus': newStatus.toString(),
          },
        );
      } catch (e, s) {
        Logger.error('Erro ao atualizar status', error: e, stackTrace: s);
        rethrow;
      }
    });
  }

  /// Busca agendamentos com filtros e paginação
  Future<List<Appointment>> fetchAppointments({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    state = const AsyncLoading();
    try {
      // Usa o caso de uso para buscar agendamentos
      final useCase = _ref.read(getAppointmentsUseCaseProvider);
      final appointments = await useCase.execute(
        page: page,
        pageSize: pageSize,
        filters: filters,
      );

      // Registra evento de analytics
      Logger.info(
        'Agendamentos buscados',
        context: {
          'page': page,
          'pageSize': pageSize,
          'count': appointments.length,
          'filters': filters,
        },
      );

      state = const AsyncData(null);
      return appointments;
    } catch (e, s) {
      Logger.error('Erro ao buscar agendamentos', error: e, stackTrace: s);
      state = AsyncError(e, s);
      return [];
    }
  }

  /// Atualiza um agendamento existente
  Future<Appointment?> updateAppointment(Appointment appointment) async {
    state = const AsyncLoading();
    try {
      // Usa o caso de uso para atualizar agendamento
      final useCase = _ref.read(updateAppointmentUseCaseProvider);
      final updatedAppointment = await useCase.execute(appointment);

      await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();

      // Registra evento de analytics
      Logger.info(
        'Agendamento atualizado',
        context: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
        },
      );

      state = const AsyncData(null);
      return updatedAppointment;
    } catch (e, s) {
      Logger.error('Erro ao atualizar agendamento', error: e, stackTrace: s);
      state = AsyncError(e, s);
      return null;
    }
  }
}

/// Extension para adicionar getters úteis ao enum AppointmentStatus.
extension AppointmentStatusX on AppointmentStatus {
  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  // ... outros getters como icon e text podem ser adicionados aqui.
}
