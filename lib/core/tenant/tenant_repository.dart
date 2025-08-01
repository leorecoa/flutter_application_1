import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/api_service.dart';

/// Repositório para gerenciar tenants
class TenantRepository {
  final ApiService _apiService;
  
  /// Construtor
  TenantRepository(this._apiService);
  
  /// Provider para o repositório de tenants
  static final provider = Provider<TenantRepository>((ref) {
    final apiService = ref.watch(ApiService.provider);
    return TenantRepository(apiService);
  });
  
  /// Verifica se um tenant tem acesso a um recurso
  Future<bool> checkTenantAccess(String tenantId, String resource) async {
    // Em desenvolvimento, sempre retorna true
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}