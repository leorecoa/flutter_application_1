import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

/// Provider para o serviço de API
///
/// Este provider fornece uma instância única do ApiService para toda a aplicação.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});