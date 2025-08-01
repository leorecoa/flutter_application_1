import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../logging/logger.dart';
import '../analytics/analytics_service.dart';
import '../tenant/tenant_context.dart';
import '../errors/app_exceptions.dart';

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
  Future<http.Response> onResponse(
    String method,
    Uri uri,
    http.Response response, {
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
      // Converte erros HTTP em exceções da aplicação
      final appError = _mapErrorToAppException(error);
      
      // Registra o erro no logger
      Logger.error('API Error', error: appError, context: {
        'method': method,
        'uri': uri.toString(),
        'errorType': appError.runtimeType.toString(),
      });
      
      // Registra o erro no analytics
      _analytics.trackError(
        'api_error',
        appError.toString(),
        parameters: {
          'method': method,
          'path': uri.path,
          'errorType': appError.runtimeType.toString(),
        },
      );
      
      return appError;
    } catch (e) {
      Logger.error('Erro ao interceptar erro', error: e);
      return error;
    }
  }
  
  /// Mapeia um erro para uma exceção da aplicação
  dynamic _mapErrorToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }
    
    if (error is http.ClientException) {
      return NetworkException(
        NetworkErrorType.serverUnreachable,
        'Não foi possível conectar ao servidor: ${error.message}',
      );
    }
    
    if (error is FormatException) {
      return ServerException(
        0,
        'Erro ao processar resposta do servidor: ${error.message}',
      );
    }
    
    return ServiceException('Erro desconhecido: $error');
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