import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logger.dart';
import '../services/storage_service.dart';
import 'tenant_model.dart';

/// Provider para o contexto do tenant
final tenantContextProvider = Provider<TenantContext>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return TenantContext(storageService);
});

/// Classe que gerencia o contexto do tenant atual
class TenantContext {
  TenantContext(this._storageService);
  
  final StorageService _storageService;
  
  Tenant? _currentTenant;
  User? _currentUser;
  
  /// Tenant atual
  Tenant? get currentTenant => _currentTenant;
  
  /// Usuário atual
  User? get currentUser => _currentUser;
  
  /// Inicializa o contexto do tenant
  Future<void> initialize() async {
    try {
      // Carrega o tenant e usuário do armazenamento local
      final tenantJson = await _storageService.getValue('current_tenant');
      final userJson = await _storageService.getValue('current_user');
      
      if (tenantJson != null) {
        _currentTenant = Tenant.fromJson(tenantJson);
      }
      
      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
      }
      
      Logger.info('Contexto do tenant inicializado', context: {
        'tenantId': _currentTenant?.id,
        'tenantName': _currentTenant?.name,
        'userId': _currentUser?.id,
      });
    } catch (e) {
      Logger.error('Erro ao inicializar contexto do tenant', error: e);
      throw Exception('Erro ao inicializar contexto do tenant: $e');
    }
  }
  
  /// Define o tenant atual
  Future<void> setCurrentTenant(Tenant tenant) async {
    try {
      _currentTenant = tenant;
      await _storageService.setValue('current_tenant', tenant.toJson());
      
      Logger.info('Tenant atual definido', context: {
        'tenantId': tenant.id,
        'tenantName': tenant.name,
      });
    } catch (e) {
      Logger.error('Erro ao definir tenant atual', error: e);
      throw Exception('Erro ao definir tenant atual: $e');
    }
  }
  
  /// Define o usuário atual
  Future<void> setCurrentUser(User user) async {
    try {
      _currentUser = user;
      await _storageService.setValue('current_user', user.toJson());
      
      Logger.info('Usuário atual definido', context: {
        'userId': user.id,
        'userName': user.name,
      });
    } catch (e) {
      Logger.error('Erro ao definir usuário atual', error: e);
      throw Exception('Erro ao definir usuário atual: $e');
    }
  }
  
  /// Limpa o contexto do tenant
  Future<void> clear() async {
    try {
      _currentTenant = null;
      _currentUser = null;
      await _storageService.removeValue('current_tenant');
      await _storageService.removeValue('current_user');
      
      Logger.info('Contexto do tenant limpo');
    } catch (e) {
      Logger.error('Erro ao limpar contexto do tenant', error: e);
      throw Exception('Erro ao limpar contexto do tenant: $e');
    }
  }
}