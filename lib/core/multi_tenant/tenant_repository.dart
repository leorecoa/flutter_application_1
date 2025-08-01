import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_model.dart';
import '../errors/app_exceptions.dart';
import '../services/api_service.dart';

/// Repositório para gerenciar tenants
class TenantRepository {
  final ApiService _apiService;

  TenantRepository(this._apiService);

  /// Obtém todos os tenants disponíveis para o usuário atual
  Future<List<Tenant>> getUserTenants() async {
    try {
      final response = await _apiService.get('/tenants');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => Tenant.fromJson(json)).toList();
      }

      throw RepositoryException(
        response['message'] ?? 'Erro ao buscar tenants',
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Erro ao buscar tenants: $e');
    }
  }

  /// Obtém um tenant específico pelo ID
  Future<Tenant> getTenantById(String tenantId) async {
    try {
      final response = await _apiService.get('/tenants/$tenantId');

      if (response['success'] == true) {
        return Tenant.fromJson(response['data']);
      }

      throw RepositoryException(response['message'] ?? 'Erro ao buscar tenant');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Erro ao buscar tenant: $e');
    }
  }

  /// Cria um novo tenant
  Future<Tenant> createTenant(Tenant tenant) async {
    try {
      final response = await _apiService.post('/tenants', tenant.toJson());

      if (response['success'] == true) {
        return Tenant.fromJson(response['data']);
      }

      throw RepositoryException(response['message'] ?? 'Erro ao criar tenant');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Erro ao criar tenant: $e');
    }
  }

  /// Atualiza um tenant existente
  Future<Tenant> updateTenant(Tenant tenant) async {
    try {
      final response = await _apiService.put(
        '/tenants/${tenant.id}',
        tenant.toJson(),
      );

      if (response['success'] == true) {
        return Tenant.fromJson(response['data']);
      }

      throw RepositoryException(
        response['message'] ?? 'Erro ao atualizar tenant',
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Erro ao atualizar tenant: $e');
    }
  }
}

/// Provider para o repositório de tenants
final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TenantRepository(apiService);
});

/// Provider para a lista de tenants do usuário atual
final userTenantsProvider = FutureProvider<List<Tenant>>((ref) async {
  final repository = ref.watch(tenantRepositoryProvider);
  return repository.getUserTenants();
});
