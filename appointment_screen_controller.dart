import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/analytics/analytics_service.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/core/tenant/tenant_repository.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart' as model;
import 'appointment_providers.dart';
import 'service_providers.dart';
import 'appointment_usecases.dart';

/// Provider para o controller da tela de agendamentos.
final appointmentScreenControllerProvider = StateNotifierProvider.autoDispose<
    AppointmentScreenController, AsyncValue<void>>(
  (ref) => AppointmentScreenController(ref),
);

/// Controller que gerencia a lógica de negócio da tela de agendamentos.
class AppointmentScreenController extends StateNotifier<AsyncValue<void>> {
  AppointmentScreenController(this._ref) : super(const AsyncData(null)) {
    // Inicializa o contexto do tenant e analytics ao criar o controller
    _initTenantContext();
  }

  final Ref _ref;
  
  /// Inicializa o contexto do tenant para o usuário atual
  Future<void> _initTenantContext() async {
    try {
      final tenantContext = _ref.read(tenantContextProvider);
      await tenantContext.initialize();
      Logger.info('Contexto do tenant inicializado', context: {
        'tenantId': tenantContext.currentTenant?.id,
        'tenantName': tenantContext.currentTenant?.name,
      });
      
      // Inicializa o analytics com o evento de sessão iniciada
      // Em desenvolvimento, isso será apenas registrado localmente
      final analytics = _ref.read(analyticsServiceProvider);
      await analytics.trackEvent('session_started', parameters: {
        'screen': 'appointment_screen',
      });
    } catch (e) {
      Logger.error('Erro ao inicializar contexto do tenant', error: e);
    }
  }
  
  /// Exporta agendamentos para o formato especificado
  Future<String?> exportAppointments({String format = 'csv'}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
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
          throw UnauthorizedException('Seu plano não permite exportação de dados');
        }
        
        // Usa o caso de uso para exportar agendamentos
        final useCase = _ref.read(exportAppointmentsUseCaseProvider);
        final exportData = await useCase.execute(format: format);
        
        // Salva o arquivo exportado
        final storageService = _ref.read(storageServiceProvider);
        final fileName = 'agendamentos_${DateTime.now().millisecondsSinceEpoch}.$format';
        final filePath = await storageService.saveToDownloads(fileName, exportData);
        
        // Registra evento de analytics (apenas localmente em desenvolvimento)
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointments_exported', parameters: {
          'format': format,
          'count': exportData.length,
          'filePath': filePath,
        });
        
        Logger.info('Agendamentos exportados', context: {
          'format': format,
          'filePath': filePath,
        });
        
        return filePath;
      } on UnauthorizedException catch (e) {
        Logger.error('Acesso negado ao exportar agendamentos', error: e);
        throw e.message;
      } on UseCaseException catch (e) {
        Logger.error('Erro ao exportar agendamentos', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao exportar agendamentos', error: e);
        throw 'Erro ao exportar agendamentos: $e';
      }
    });
    return result.asData?.value;
  }

  /// Cria múltiplos agendamentos recorrentes de forma otimizada.
  Future<void> createRecurringAppointments(
      List<model.Appointment> appointments) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para criar agendamentos recorrentes
        final useCase = _ref.read(createRecurringAppointmentsUseCaseProvider);
        final createdAppointments = await useCase.execute(appointments);
        
        // Recarrega a lista de agendamentos uma única vez
        await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        
        // Registra evento de analytics
        Logger.info('Agendamentos recorrentes criados', context: {
          'count': createdAppointments.length,
          'firstDate': createdAppointments.first.dateTime.toIso8601String(),
        });
      } on UseCaseException catch (e) {
        Logger.error('Erro ao criar agendamentos recorrentes', error: e);
        throw e.message;
      } on ValidationException catch (e) {
        Logger.error('Erro de validação ao criar agendamentos', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao criar agendamentos recorrentes', error: e);
        throw 'Erro ao criar agendamentos: $e';
      }
    });
  }

  /// Exclui um agendamento e suas notificações.
  Future<void> deleteAppointment(model.Appointment appointment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para excluir agendamento
        final useCase = _ref.read(deleteAppointmentUseCaseProvider);
        await useCase.execute(appointment.id);
        
        // Recarrega a lista de agendamentos
        await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        
        // Registra evento de analytics
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointment_deleted', parameters: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
        });
        
        Logger.info('Agendamento excluído', context: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
        });
      } on UseCaseException catch (e) {
        Logger.error('Erro ao excluir agendamento', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao excluir agendamento', error: e);
        throw 'Erro ao excluir agendamento: $e';
      }
    });
  }

  /// Atualiza o status de um agendamento (confirmado/cancelado).
  Future<void> updateAppointmentStatus(
      String appointmentId, String newStatus) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para atualizar status
        final useCase = _ref.read(updateAppointmentStatusUseCaseProvider);
        await useCase.execute(appointmentId, newStatus);
        
        // Recarrega a lista de agendamentos
        await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        
        // Registra evento de analytics
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointment_status_updated', parameters: {
          'appointmentId': appointmentId,
          'newStatus': newStatus,
        });
        
        Logger.info('Status de agendamento atualizado', context: {
          'appointmentId': appointmentId,
          'newStatus': newStatus,
        });
      } on UseCaseException catch (e) {
        Logger.error('Erro ao atualizar status', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao atualizar status', error: e);
        throw 'Erro ao atualizar status: $e';
      }
    });
  }
  
  /// Busca agendamentos com filtros e paginação
  Future<List<model.Appointment>> fetchAppointments({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para buscar agendamentos
        final useCase = _ref.read(getAppointmentsUseCaseProvider);
        final appointments = await useCase.execute(
          page: page,
          pageSize: pageSize,
          filters: filters,
        );
        
        // Registra evento de analytics
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointments_fetched', parameters: {
          'page': page,
          'pageSize': pageSize,
          'count': appointments.length,
          'filters': filters?.toString(),
        });
        
        Logger.info('Agendamentos buscados', context: {
          'page': page,
          'pageSize': pageSize,
          'count': appointments.length,
          'filters': filters,
        });
        
        return appointments;
      } on UseCaseException catch (e) {
        Logger.error('Erro ao buscar agendamentos', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao buscar agendamentos', error: e);
        throw 'Erro ao buscar agendamentos: $e';
      }
    });
    
    state = result;
    return result.asData?.value ?? [];
  }
  
  /// Atualiza um agendamento existente
  Future<model.Appointment?> updateAppointment(model.Appointment appointment) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para atualizar agendamento
        final useCase = _ref.read(updateAppointmentUseCaseProvider);
        final updatedAppointment = await useCase.execute(appointment);
        
        // Recarrega a lista de agendamentos
        await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        
        // Registra evento de analytics
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointment_updated', parameters: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
          'service': appointment.serviceName,
        });
        
        Logger.info('Agendamento atualizado', context: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
        });
        
        return updatedAppointment;
      } on UseCaseException catch (e) {
        Logger.error('Erro ao atualizar agendamento', error: e);
        throw e.message;
      } on ValidationException catch (e) {
        Logger.error('Erro de validação ao atualizar agendamento', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao atualizar agendamento', error: e);
        throw 'Erro ao atualizar agendamento: $e';
      }
    });
    
    state = result;
    return result.asData?.value;
  }: page,
          'pageSize': pageSize,
          'count': appointments.length,
          'filters': filters?.void @override
  void toString(),
        });
        
        void Logger.info('Agendamentos buscados', context = {
          'page': page,
          'pageSize': pageSize,
          'count': appointments.length,
          'filters': filters,
        });
        
        return appointments;
      } on UseCaseException void catch (e) {
        Logger.error('Erro ao buscar agendamentos', error: e);
        throw e.message;
      } void catch (e) {
        Logger.error('Erro ao buscar agendamentos', error: e);
        throw 'Erro ao buscar agendamentos: $e';
      }
    });
    
    state = result;
    return void result.asData?.value ?? [];
  }
  
  /// Atualiza um agendamento existente
  Future<model.Appointment?> updateAppointment(model.Appointment appointment) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      try {
        // Usa o caso de uso para atualizar agendamento
        final useCase = _ref.read(updateAppointmentUseCaseProvider);
        final updatedAppointment = await useCase.execute(appointment);
        
        // Recarrega a lista de agendamentos
        await _ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
        
        // Registra evento de analytics
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.trackEvent('appointment_updated', parameters: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
          'service': appointment.service,
        });
        
        Logger.info('Agendamento atualizado', context: {
          'appointmentId': appointment.id,
          'clientName': appointment.clientName,
        });
        
        return updatedAppointment;
      } on UseCaseException catch (e) {
        Logger.error('Erro ao atualizar agendamento', error: e);
        throw e.message;
      } on ValidationException catch (e) {
        Logger.error('Erro de validação ao atualizar agendamento', error: e);
        throw e.message;
      } catch (e) {
        Logger.error('Erro ao atualizar agendamento', error: e);
        throw 'Erro ao atualizar agendamento: $e';
      }
    });
    
    state = result;
    return result.asData?.value;
  }
}

/// Extension para adicionar getters úteis ao status de agendamento.
extension AppointmentStatusX on String {
  bool get isConfirmed => toLowerCase() == 'confirmed';
  bool get isCancelled => toLowerCase() == 'cancelled';
  bool get isPending => toLowerCase() == 'scheduled';
  bool get isCompleted => toLowerCase() == 'completed';

  Color get statusColor {
    switch (toLowerCase()) {
      case 'scheduled':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData get statusIcon {
    switch (toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  String get statusText {
    switch (toLowerCase()) {
      case 'scheduled':
        return 'Agendado';
      case 'confirmed':
        return 'Confirmado';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }
}