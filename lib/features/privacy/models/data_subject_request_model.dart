// Modelo para solicitações de titulares de dados (LGPD/GDPR)

/// Tipos de solicitação de titular de dados
enum RequestType {
  access,        // Acesso aos dados
  rectification, // Correção de dados
  erasure,       // Exclusão de dados
  restriction,   // Restrição de processamento
  portability,   // Portabilidade de dados
  objection,     // Objeção ao processamento
  automated,     // Decisões automatizadas
}

/// Status da solicitação
enum RequestStatus {
  pending,
  inProgress,
  completed,
  rejected,
  cancelled,
}

/// Modelo para solicitações de titulares de dados (LGPD/GDPR)
class DataSubjectRequestModel {
  final String id;
  final String userId;
  final RequestType type;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String description;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final String? rejectionReason;

  DataSubjectRequestModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.description,
    this.attachments,
    this.metadata,
    this.rejectionReason,
  });

  factory DataSubjectRequestModel.fromJson(Map<String, dynamic> json) {
    return DataSubjectRequestModel(
      id: json['id'],
      userId: json['userId'],
      type: RequestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RequestType.access,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      description: json['description'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      metadata: json['metadata'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'description': description,
      'attachments': attachments,
      'metadata': metadata,
      'rejectionReason': rejectionReason,
    };
  }

  DataSubjectRequestModel copyWith({
    String? id,
    String? userId,
    RequestType? type,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? description,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? rejectionReason,
  }) {
    return DataSubjectRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}