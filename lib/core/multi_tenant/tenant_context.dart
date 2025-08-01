import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tenant_model.dart';
import '../errors/app_exceptions.dart';

/// Contexto do tenant atual
class TenantContext extends StateNotifier<Tenant?> {
  TenantContext() : super(null);
  
  /// Obtém o ID do tenant atual
  String get currentTenantId => state?.id ?? '';
  
  /// Obtém o nome do tenant atual
  String get currentTenantName => state?.name ?? '';
  
  /// Verifica se há um tenant selecionado
  bool get hasTenant => state != null;
  
  /// Define o tenant atual
  void setTenant(Tenant tenant) {
    state = tenant;
  }
  
  /// Limpa o tenant atual
  void clearTenant() {
    state = null;
  }
  
  /// Verifica se o usuário tem acesso ao tenant
  void validateTenantAccess(String tenantId) {
    if (state == null) {
      throw TenantException('Nenhum tenant selecionado');
    }
    
    if (state!.id != tenantId) {
      throw TenantException('Acesso negado ao tenant $tenantId');
    }
  }
}

/// Provider para o contexto do tenant
final tenantContextProvider = StateNotifierProvider<TenantContext, Tenant?>((ref) {
  return TenantContext();
});

/// Middleware para verificar acesso ao tenant
class TenantMiddleware extends ConsumerWidget {
  final Widget child;
  final String? requiredTenantId;
  
  const TenantMiddleware({
    Key? key,
    required this.child,
    this.requiredTenantId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantContext = ref.watch(tenantContextProvider.notifier);
    
    // Se não há requisito específico de tenant, apenas renderiza o filho
    if (requiredTenantId == null) {
      return child;
    }
    
    // Verifica se há um tenant selecionado
    if (!tenantContext.hasTenant) {
      return const _TenantSelectionRequired();
    }
    
    // Verifica se o tenant atual tem acesso ao recurso
    if (tenantContext.currentTenantId != requiredTenantId) {
      return const _TenantAccessDenied();
    }
    
    // Acesso permitido
    return child;
  }
}

/// Widget exibido quando é necessário selecionar um tenant
class _TenantSelectionRequired extends StatelessWidget {
  const _TenantSelectionRequired();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Selecione uma empresa para continuar',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/select-tenant');
              },
              child: const Text('Selecionar Empresa'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget exibido quando o acesso ao tenant é negado
class _TenantAccessDenied extends StatelessWidget {
  const _TenantAccessDenied();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Acesso negado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você não tem permissão para acessar este recurso',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/dashboard');
              },
              child: const Text('Voltar para o Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}