import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contexto do tenant para isolamento de dados
abstract class TenantContext {
  String get currentTenantId;
  String get currentTenantName;
  bool get isMultiTenant;
}

/// Implementação local do TenantContext
class LocalTenantContext implements TenantContext {
  static final LocalTenantContext _instance = LocalTenantContext._internal();
  factory LocalTenantContext() => _instance;
  LocalTenantContext._internal();

  @override
  String get currentTenantId => 'local-tenant-1';

  @override
  String get currentTenantName => 'Meu Negócio';

  @override
  bool get isMultiTenant => false;
}
