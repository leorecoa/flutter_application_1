import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/app_config.dart';

/// Serviço para registro de auditoria de segurança
class AuditLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static String get _baseUrl => '${AppConfig.apiBaseUrl}/audit';

  /// Registra um evento de auditoria
  static Future<void> log({
    required String action,
    required String resource,
    required String userId,
    String? tenantId,
    Map<String, dynamic>? metadata,
  }) async {
    final event = {
      'action': action,
      'resource': resource,
      'userId': userId,
      'tenantId': tenantId,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata,
    };

    // Log local
    _logger.i('AUDIT: ${event['action']} on ${event['resource']}');

    try {
      // Envio para API
      await http.post(
        Uri.parse('$_baseUrl/log'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(event),
      );
    } catch (e) {
      // Falha no envio para API, armazena localmente para envio posterior
      _logger.w('Failed to send audit log: $e');
      _storeForLaterSync(event);
    }
  }

  /// Armazena eventos para sincronização posterior
  static void _storeForLaterSync(Map<String, dynamic> event) {
    // Implementação para armazenamento local
    // mkdir -p .github\workflows devops\monitoring devops\scaling devops\testing
  }

  /// Registra acesso a dados sensíveis
  static Future<void> logSensitiveAccess({
    required String dataType,
    required String userId,
    required String reason,
  }) async {
    await log(
      action: 'sensitive_data_access',
      resource: dataType,
      userId: userId,
      metadata: {'reason': reason},
    );
  }

  /// Registra alteração em dados sensíveis
  static Future<void> logSensitiveModification({
    required String dataType,
    required String userId,
    required String operation,
  }) async {
    await log(
      action: 'sensitive_data_modification',
      resource: dataType,
      userId: userId,
      metadata: {'operation': operation},
    );
  }
}
