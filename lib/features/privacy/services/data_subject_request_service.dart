import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../../../core/security/audit_logger.dart';
import '../models/data_subject_request_model.dart';

/// Serviço para gerenciamento de solicitações de titulares de dados (LGPD/GDPR)
class DataSubjectRequestService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/privacy/dsr';
  static const _uuid = Uuid();
  
  /// Obtém todas as solicitações do usuário
  static Future<List<DataSubjectRequestModel>> getUserRequests(String userId) async {
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
        return data.map((item) => DataSubjectRequestModel.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao obter solicitações: ${response.statusCode}');
      }
    } catch (e) {
      // Dados simulados para desenvolvimento
      return _getMockRequests(userId);
    }
  }
  
  /// Cria uma nova solicitação
  static Future<DataSubjectRequestModel> createRequest({
    required String userId,
    required RequestType type,
    required String description,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) async {
    final request = DataSubjectRequestModel(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      description: description,
      attachments: attachments,
      metadata: metadata,
    );
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        // Registra evento de auditoria
        await AuditLogger.log(
          action: 'dsr_created',
          resource: 'dsr/${type.name}',
          userId: userId,
          metadata: {'requestId': request.id},
        );
        
        return DataSubjectRequestModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao criar solicitação: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      // Registra evento de auditoria mesmo em caso de falha
      await AuditLogger.log(
        action: 'dsr_created',
        resource: 'dsr/${type.name}',
        userId: userId,
        metadata: {'requestId': request.id, 'offline': true},
      );
      
      return request;
    }
  }
  
  /// Atualiza o status de uma solicitação
  static Future<DataSubjectRequestModel> updateRequestStatus({
    required String requestId,
    required String userId,
    required RequestStatus status,
    String? rejectionReason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$requestId/status'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'status': status.name,
          'completedAt': status == RequestStatus.completed ? DateTime.now().toIso8601String() : null,
          'rejectionReason': rejectionReason,
        }),
      );

      if (response.statusCode == 200) {
        // Registra evento de auditoria
        await AuditLogger.log(
          action: 'dsr_status_updated',
          resource: 'dsr/$requestId',
          userId: userId,
          metadata: {'status': status.name},
        );
        
        return DataSubjectRequestModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao atualizar status da solicitação: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      final existingRequests = await getUserRequests(userId);
      final existingRequest = existingRequests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => throw Exception('Solicitação não encontrada'),
      );
      
      final updatedRequest = existingRequest.copyWith(
        status: status,
        completedAt: status == RequestStatus.completed ? DateTime.now() : null,
        rejectionReason: rejectionReason,
      );
      
      // Registra evento de auditoria mesmo em caso de falha
      await AuditLogger.log(
        action: 'dsr_status_updated',
        resource: 'dsr/$requestId',
        userId: userId,
        metadata: {'status': status.name, 'offline': true},
      );
      
      return updatedRequest;
    }
  }
  
  /// Exporta dados do usuário (para solicitações de acesso ou portabilidade)
  static Future<String> exportUserData(String userId, {String format = 'json'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/export/$userId?format=$format'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );

      if (response.statusCode == 200) {
        // Registra evento de auditoria
        await AuditLogger.log(
          action: 'user_data_exported',
          resource: 'user/$userId',
          userId: userId,
          metadata: {'format': format},
        );
        
        return response.body;
      } else {
        throw Exception('Falha ao exportar dados: ${response.statusCode}');
      }
    } catch (e) {
      // Simulação para desenvolvimento
      // Registra evento de auditoria mesmo em caso de falha
      await AuditLogger.log(
        action: 'user_data_exported',
        resource: 'user/$userId',
        userId: userId,
        metadata: {'format': format, 'offline': true},
      );
      
      // Retorna dados simulados
      return json.encode({
        'userId': userId,
        'personalData': {
          'name': 'Usuário Teste',
          'email': 'usuario@teste.com',
          'phone': '(11) 98765-4321',
        },
        'appointments': [
          {
            'id': 'appt-123',
            'date': '2023-07-15T14:00:00Z',
            'service': 'Corte de Cabelo',
          }
        ],
        'preferences': {
          'notifications': true,
          'theme': 'light',
        },
        'exportDate': DateTime.now().toIso8601String(),
      });
    }
  }
  
  /// Gera dados simulados para desenvolvimento
  static List<DataSubjectRequestModel> _getMockRequests(String userId) {
    return [
      DataSubjectRequestModel(
        id: '1',
        userId: userId,
        type: RequestType.access,
        status: RequestStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        description: 'Solicito acesso a todos os meus dados pessoais.',
      ),
      DataSubjectRequestModel(
        id: '2',
        userId: userId,
        type: RequestType.rectification,
        status: RequestStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Preciso corrigir meu número de telefone.',
        metadata: {'field': 'phone', 'newValue': '(11) 98765-4321'},
      ),
      DataSubjectRequestModel(
        id: '3',
        userId: userId,
        type: RequestType.erasure,
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Solicito a exclusão de todos os meus dados de pagamento.',
      ),
    ];
  }
}