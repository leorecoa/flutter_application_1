/// Modelo de dados para representar um tenant (empresa/organização)
class Tenant {
  final String id;
  final String name;
  final String plan;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> settings;
  
  Tenant({
    required this.id,
    required this.name,
    required this.plan,
    required this.createdAt,
    required this.isActive,
    this.settings = const {},
  });
  
  /// Cria um Tenant a partir de um mapa JSON
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      plan: json['plan'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }
  
  /// Converte o Tenant para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan': plan,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'settings': settings,
    };
  }
  
  /// Cria uma cópia do Tenant com alguns campos alterados
  Tenant copyWith({
    String? id,
    String? name,
    String? plan,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? settings,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
    );
  }
}