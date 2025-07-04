import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../../../core/security/audit_logger.dart';
import '../models/consent_model.dart';

/// Serviço para gerenciamento de consentimentos
class ConsentService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/privacy/consent';
  static const String _currentVersion = '1.0.0';
  static const _uuid = Uuid();

  /// Obtém todos os consentimentos do usuário
  static Future<List<ConsentModel>> getUserConsents(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ConsentModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Falha ao obter consentimentos: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return _getMockConsents(userId);
    }
  }

  /// Registra um novo consentimento
  static Future<ConsentModel> registerConsent({
    required String userId,
    required ConsentType type,
    required ConsentStatus status,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    final consent = ConsentModel(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      status: status,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      version: _currentVersion,
      metadata: metadata,
    );

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode(consent.toJson()),
      );

      if (response.statusCode == 201) {
        // Registra evento de auditoria
        await AuditLogger.log(
          action: 'consent_registered',
          resource: 'consent/${type.name}',
          userId: userId,
          metadata: {'status': status.name},
        );

        return ConsentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Falha ao registrar consentimento: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      // Registra evento de auditoria mesmo em caso de falha
      await AuditLogger.log(
        action: 'consent_registered',
        resource: 'consent/${type.name}',
        userId: userId,
        metadata: {'status': status.name, 'offline': true},
      );

      return consent;
    }
  }

  /// Atualiza um consentimento existente
  static Future<ConsentModel> updateConsent({
    required String consentId,
    required String userId,
    required ConsentStatus status,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$consentId'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'status': status.name,
          'updatedAt': DateTime.now().toIso8601String(),
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        // Registra evento de auditoria
        await AuditLogger.log(
          action: 'consent_updated',
          resource: 'consent/$consentId',
          userId: userId,
          metadata: {'status': status.name},
        );

        return ConsentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Falha ao atualizar consentimento: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      final existingConsents = await getUserConsents(userId);
      final existingConsent = existingConsents.firstWhere(
        (c) => c.id == consentId,
        orElse: () => throw Exception('Consentimento não encontrado'),
      );

      final updatedConsent = existingConsent.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        metadata: metadata ?? existingConsent.metadata,
      );

      // Registra evento de auditoria mesmo em caso de falha
      await AuditLogger.log(
        action: 'consent_updated',
        resource: 'consent/$consentId',
        userId: userId,
        metadata: {'status': status.name, 'offline': true},
      );

      return updatedConsent;
    }
  }

  /// Verifica se o usuário deu consentimento para um tipo específico
  static Future<bool> hasConsent(String userId, ConsentType type) async {
    final consents = await getUserConsents(userId);
    final consent = consents.where((c) => c.type == type).toList();

    if (consent.isEmpty) {
      return false;
    }

    // Pega o consentimento mais recente
    consent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return consent.first.status == ConsentStatus.granted;
  }

  /// Gera dados simulados para desenvolvimento
  static List<ConsentModel> _getMockConsents(String userId) {
    return [
      ConsentModel(
        id: '1',
        userId: userId,
        type: ConsentType.marketing,
        status: ConsentStatus.granted,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        version: _currentVersion,
      ),
      ConsentModel(
        id: '2',
        userId: userId,
        type: ConsentType.analytics,
        status: ConsentStatus.granted,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        version: _currentVersion,
      ),
      ConsentModel(
        id: '3',
        userId: userId,
        type: ConsentType.thirdParty,
        status: ConsentStatus.denied,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        version: _currentVersion,
      ),
      ConsentModel(
        id: '4',
        userId: userId,
        type: ConsentType.cookies,
        status: ConsentStatus.granted,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        expiresAt: DateTime.now().add(const Duration(days: 335)),
        version: _currentVersion,
      ),
    ];
  }
}
