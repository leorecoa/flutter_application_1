import '../../domain/repositories/appointment_repository.dart';
import '../../core/tenant/tenant_context.dart';

/// Caso de uso para buscar agendamentos
class GetAppointmentsUseCase {
  final AppointmentRepository _repository;
  final TenantContext _tenantContext;

  GetAppointmentsUseCase(this._repository, this._tenantContext);

  /// Executa a busca de agendamentos
  Future<List<dynamic>> execute({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Adiciona o tenant ID aos filtros se necessário
      final updatedFilters = Map<String, dynamic>.from(filters ?? {});
      if (_tenantContext.isMultiTenant) {
        updatedFilters['tenantId'] = _tenantContext.currentTenantId;
      }

      return await _repository.getAppointments(
        page: page,
        pageSize: pageSize,
        filters: updatedFilters,
      );
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }
}
