import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/analytics/analytics_service.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';

/// Provider para o interceptor de API
final apiInterceptorProvider = Provider<ApiInterceptor>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);
  final tenantContext = ref.watch(tenantContextProvider);
  return ApiInterceptor(analytics, tenantContext);
});

/// Classe para interceptar requisições HTTP
class ApiInterceptor {
  ApiInterceptor(this._analytics, this._tenantContext);
  
  final AnalyticsService _analytics;
  final TenantContext _tenantContext;
  
  /// Intercepta uma requisição antes de ser enviada
  Future<InterceptedRequest> onRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) async {
    try {
      // Adiciona headers específicos do tenant
      final tenantId = _tenantContext.currentTenant?.id;
      final userId = _tenantContext.currentUser?.id;
      
      final enrichedHeaders = {
        ...?headers,
        if (tenantId != null) 'X-Tenant-ID': tenantId,
        if (userId != null) 'X-User-ID': userId,
      };
      
      // Registra a requisição no logger
      Logger.info('API Request', context: {
        'method': method,
        'uri': uri.toString(),
        'tenantId': tenantId,
        'userId': userId,
      });
      
      return InterceptedRequest(
        uri: uri,
        headers: enrichedHeaders,
        body: body,
      );
    } catch (e) {
      Logger.error('Erro ao interceptar requisição', error: e);
      rethrow;
    }
  }
  
  /// Intercepta uma resposta antes de ser processada
  Future<dynamic> onResponse(
    String method,
    Uri uri,
    dynamic response, {
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final statusCode = response.statusCode;
      final isSuccess = statusCode >= 200 && statusCode < 300;
      final duration = endTime != null && startTime != null
          ? endTime.difference(startTime).inMilliseconds
          : null;
      
      // Registra a resposta no logger
      Logger.info(
        isSuccess ? 'API Response Success' : 'API Response Error',
        context: {
          'method': method,
          'uri': uri.toString(),
          'statusCode': statusCode,
          'durationMs': duration,
          'responseSize': response.body.length,
        },
      );
      
      // Registra métricas de API no analytics
      _analytics.trackEvent('api_call', parameters: {
        'method': method,
        'path': uri.path,
        'statusCode': statusCode,
        'durationMs': duration,
        'success': isSuccess,
      });
      
      return response;
    } catch (e) {
      Logger.error('Erro ao interceptar resposta', error: e);
      return response;
    }
  }
  
  /// Intercepta um erro antes de ser lançado
  Future<dynamic> onError(String method, Uri uri, dynamic error) async {
    try {
      // Registra o erro no logger
      Logger.error('API Error', error: error, context: {
        'method': method,
        'uri': uri.toString(),
        'errorType': error.runtimeType.toString(),
      });
      
      // Registra o erro no analytics
      _analytics.trackError(
        'api_error',
        error.toString(),
        parameters: {
          'method': method,
          'path': uri.path,
          'errorType': error.runtimeType.toString(),
        },
      );
      
      return error;
    } catch (e) {
      Logger.error('Erro ao interceptar erro', error: e);
      return error;
    }
  }
}

/// Classe que representa uma requisição interceptada
class InterceptedRequest {
  InterceptedRequest({
    required this.uri,
    required this.headers,
    this.body,
  });
  
  final Uri uri;
  final Map<String, String> headers;
  final String? body;
}