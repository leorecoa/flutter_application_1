import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller para gerenciar o contexto do tenant (empresa) ativo.
///
/// Armazena o ID do tenant selecionado pelo usuário. Este ID é essencial
/// para todas as operações de banco de dados e armazenamento, garantindo
/// o isolamento de dados (multi-tenancy).
class TenantContextController extends StateNotifier<String?> {
  TenantContextController() : super(null);

  /// Define o tenant ativo. Chamado após o login e seleção de empresa.
  void setTenant(String tenantId) {
    state = tenantId;
  }

  /// Limpa o tenant ativo. Chamado durante o logout.
  void clearTenant() {
    state = null;
  }
}

final tenantProvider =
    StateNotifierProvider<TenantContextController, String?>((ref) {
  return TenantContextController();
});
