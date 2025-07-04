// Modelo para registro de consentimento

/// Tipos de consentimento
enum ConsentType {
  marketing,
  analytics,
  thirdParty,
  profiling,
  location,
  cookies,
  communications,
}

/// Status do consentimento
enum ConsentStatus {
  granted,
  denied,
  pending,
  expired,
}

/// Modelo para registro de consentimento
class ConsentModel {
  final String id;
  final String userId;
  final ConsentType type;
  final ConsentStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final String version;
  final Map<String, dynamic>? metadata;

  ConsentModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.version,
    this.expiresAt,
    this.updatedAt,
    this.metadata,
  });

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      id: json['id'],
      userId: json['userId'],
      type: ConsentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ConsentType.marketing,
      ),
      status: ConsentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['version'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
      'metadata': metadata,
    };
  }

  ConsentModel copyWith({
    String? id,
    String? userId,
    ConsentType? type,
    ConsentStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? updatedAt,
    String? version,
    Map<String, dynamic>? metadata,
  }) {
    return ConsentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }
}
