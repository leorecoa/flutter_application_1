import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/core/services/api_service.dart';

/// Provider para o contexto do tenant
final tenantContextProvider = Provider<TenantContext>((ref) {
  return TenantContext();
});

/// Provider para o serviço API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});