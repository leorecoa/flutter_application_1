import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para exportar agendamentos
class ExportAppointmentsUseCase {
  final AppointmentRepository _repository;
  final TenantContext _tenantContext;

  /// Construtor
  ExportAppointmentsUseCase(this._repository, this._tenantContext);

  /// Executa o caso de uso
  Future<String> execute({required String format}) async {
    try {
      // Validação básica
      if (format.isEmpty) {
        throw ValidationException('Formato de exportação é obrigatório');
      }

      // Formatos suportados
      if (format != 'csv' && format != 'json') {
        throw ValidationException(
          'Formato não suportado: $format. Use csv ou json.',
        );
      }

      // Obtém o tenant atual
      final tenantId = _tenantContext.currentTenant?.id;
      if (tenantId == null) {
        throw UnauthorizedException('Nenhum tenant ativo');
      }

      // Exporta os agendamentos
      final exportData = await _repository.exportAppointments(
        tenantId: tenantId,
        format: format,
      );

      Logger.info(
        'Agendamentos exportados com sucesso',
        context: {'format': format},
      );

      return exportData;
    } on ValidationException catch (e) {
      Logger.error('Erro de validação ao exportar agendamentos', error: e);
      rethrow;
    } on UnauthorizedException catch (e) {
      Logger.error('Acesso negado ao exportar agendamentos', error: e);
      rethrow;
    } catch (e) {
      Logger.error('Erro ao exportar agendamentos', error: e);
      throw UseCaseException('Erro ao exportar agendamentos: $e');
    }
  }
}
