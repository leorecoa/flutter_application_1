import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import 'tenant_context.dart';
import 'tenant_model.dart';

/// Provider para o repositório de tenants
final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final tenantContext = ref.watch(tenantContextProvider);
  return TenantRepositoryImpl(tenantContext);
});

/// Interface para o repositório de tenants
abstract class TenantRepository {
  /// Obtém todos os tenants disponíveis
  Future<List<Tenant>> getAllTenants();

  /// Obtém um tenant pelo ID
  Future<Tenant> getTenantById(String id);

  /// Cria um novo tenant
  Future<Tenant> createTenant(Tenant tenant);

  /// Atualiza um tenant existente
  Future<Tenant> updateTenant(Tenant tenant);

  /// Exclui um tenant
  Future<void> deleteTenant(String id);

  /// Verifica se um tenant tem acesso a um recurso
  Future<bool> checkTenantAccess(String tenantId, String feature);

  /// Obtém estatísticas do tenant
  Future<Map<String, dynamic>> getTenantStats(String tenantId);
}

/// Implementação do repositório de tenants
class TenantRepositoryImpl implements TenantRepository {
  TenantRepositoryImpl(this._tenantContext);

  final TenantContext _tenantContext;

  @override
  Future<List<Tenant>> getAllTenants() async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        Tenant(
          id: 'tenant-1',
          name: 'Salão de Beleza Exemplo',
          plan: TenantPlan(
            id: 'basic',
            name: 'Plano Básico',
            features: ['appointments', 'clients', 'calendar'],
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Tenant(
          id: 'tenant-2',
          name: 'Clínica Exemplo',
          plan: TenantPlan(
            id: 'premium',
            name: 'Plano Premium',
            features: [
              'appointments',
              'clients',
              'calendar',
              'reports',
              'payments',
            ],
            maxUsers: 5,
            maxAppointments: 500,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
    } catch (e) {
      Logger.error('Erro ao obter todos os tenants', error: e);
      throw RepositoryException('Erro ao obter todos os tenants: $e');
    }
  }

  @override
  Future<Tenant> getTenantById(String id) async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 300));

      if (id == 'tenant-1') {
        return Tenant(
          id: 'tenant-1',
          name: 'Salão de Beleza Exemplo',
          plan: TenantPlan(
            id: 'basic',
            name: 'Plano Básico',
            features: ['appointments', 'clients', 'calendar'],
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
      } else if (id == 'tenant-2') {
        return Tenant(
          id: 'tenant-2',
          name: 'Clínica Exemplo',
          plan: TenantPlan(
            id: 'premium',
            name: 'Plano Premium',
            features: [
              'appointments',
              'clients',
              'calendar',
              'reports',
              'payments',
            ],
            maxUsers: 5,
            maxAppointments: 500,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        );
      }

      throw NotFoundException('Tenant não encontrado com ID: $id');
    } catch (e) {
      Logger.error('Erro ao obter tenant por ID', error: e);
      if (e is NotFoundException) rethrow;
      throw RepositoryException('Erro ao obter tenant por ID: $e');
    }
  }

  @override
  Future<Tenant> createTenant(Tenant tenant) async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 800));

      // Simula a criação com um ID gerado
      final createdTenant = Tenant(
        id: 'tenant-${DateTime.now().millisecondsSinceEpoch}',
        name: tenant.name,
        plan: tenant.plan,
        settings: tenant.settings,
        createdAt: DateTime.now(),
        expiresAt: tenant.expiresAt,
      );

      Logger.info(
        'Tenant criado com sucesso',
        context: {
          'tenantId': createdTenant.id,
          'tenantName': createdTenant.name,
        },
      );

      return createdTenant;
    } catch (e) {
      Logger.error('Erro ao criar tenant', error: e);
      throw RepositoryException('Erro ao criar tenant: $e');
    }
  }

  @override
  Future<Tenant> updateTenant(Tenant tenant) async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 600));

      Logger.info(
        'Tenant atualizado com sucesso',
        context: {'tenantId': tenant.id, 'tenantName': tenant.name},
      );

      return tenant;
    } catch (e) {
      Logger.error('Erro ao atualizar tenant', error: e);
      throw RepositoryException('Erro ao atualizar tenant: $e');
    }
  }

  @override
  Future<void> deleteTenant(String id) async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 500));

      Logger.info('Tenant excluído com sucesso', context: {'tenantId': id});
    } catch (e) {
      Logger.error('Erro ao excluir tenant', error: e);
      throw RepositoryException('Erro ao excluir tenant: $e');
    }
  }

  @override
  Future<bool> checkTenantAccess(String tenantId, String feature) async {
    try {
      // Verifica se o tenant atual tem acesso ao recurso
      final currentTenant = _tenantContext.currentTenant;

      if (currentTenant == null) {
        throw UnauthorizedException('Nenhum tenant ativo');
      }

      if (currentTenant.id != tenantId) {
        throw UnauthorizedException('Acesso negado a tenant diferente');
      }

      return currentTenant.hasAccess(feature);
    } catch (e) {
      Logger.error('Erro ao verificar acesso do tenant', error: e);
      if (e is UnauthorizedException) rethrow;
      throw RepositoryException('Erro ao verificar acesso do tenant: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTenantStats(String tenantId) async {
    try {
      // TODO: Implementar chamada à API real
      // Simulação de dados para desenvolvimento
      await Future.delayed(const Duration(milliseconds: 700));

      return {
        'totalUsers': 3,
        'totalAppointments': 120,
        'activeAppointments': 45,
        'completedAppointments': 75,
        'totalClients': 85,
        'lastMonthRevenue': 2500.0,
        'currentMonthRevenue': 1800.0,
      };
    } catch (e) {
      Logger.error('Erro ao obter estatísticas do tenant', error: e);
      throw RepositoryException('Erro ao obter estatísticas do tenant: $e');
    }
  }
}
