/// Modelo de dados para um tenant
class Tenant {
  /// ID único do tenant
  final String id;
  
  /// Nome do tenant
  final String name;
  
  /// Domínio personalizado (opcional)
  final String? domain;
  
  /// Plano de assinatura
  final String plan;
  
  /// Status do tenant (active, suspended, etc.)
  final String status;
  
  /// URL do logo (opcional)
  final String? logo;
  
  /// Cor primária personalizada (opcional)
  final String? primaryColor;
  
  /// Cor de destaque personalizada (opcional)
  final String? accentColor;
  
  /// Número máximo de usuários permitidos
  final int? maxUsers;
  
  /// Número máximo de clientes permitidos
  final int? maxClients;
  
  /// Lista de recursos disponíveis para o tenant
  final List<String>? features;
  
  /// Construtor
  Tenant({
    required this.id,
    required this.name,
    this.domain,
    required this.plan,
    required this.status,
    this.logo,
    this.primaryColor,
    this.accentColor,
    this.maxUsers,
    this.maxClients,
    this.features,
  });
  
  /// Verifica se o tenant está ativo
  bool get isActive => status.toLowerCase() == 'active';
  
  /// Verifica se o tenant tem acesso a um recurso específico
  bool hasFeature(String feature) {
    return features?.contains(feature) ?? false;
  }
  
  /// Cria uma cópia do tenant com campos atualizados
  Tenant copyWith({
    String? id,
    String? name,
    String? domain,
    String? plan,
    String? status,
    String? logo,
    String? primaryColor,
    String? accentColor,
    int? maxUsers,
    int? maxClients,
    List<String>? features,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      maxUsers: maxUsers ?? this.maxUsers,
      maxClients: maxClients ?? this.maxClients,
      features: features ?? this.features,
    );
  }
  
  /// Converte o modelo para um mapa (para serialização)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'plan': plan,
      'status': status,
      'logo': logo,
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'maxUsers': maxUsers,
      'maxClients': maxClients,
      'features': features,
    };
  }
  
  /// Cria um modelo a partir de um mapa (para deserialização)
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      domain: json['domain'],
      plan: json['plan'],
      status: json['status'],
      logo: json['logo'],
      primaryColor: json['primaryColor'],
      accentColor: json['accentColor'],
      maxUsers: json['maxUsers'],
      maxClients: json['maxClients'],
      features: json['features'] != null 
          ? List<String>.from(json['features']) 
          : null,
    );
  }
}