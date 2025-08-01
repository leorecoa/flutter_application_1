/// Modelo que representa um tenant no sistema multi-tenant
class Tenant {
  Tenant({
    required this.id,
    required this.name,
    required this.plan,
    this.settings = const {},
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String name;
  final TenantPlan plan;
  final Map<String, dynamic> settings;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  
  /// Verifica se o tenant está ativo
  bool get isActive {
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(DateTime.now());
  }
  
  /// Verifica se o tenant tem acesso a um recurso específico
  bool hasAccess(String feature) {
    return plan.features.contains(feature);
  }
  
  /// Cria um Tenant a partir de um mapa JSON
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      plan: TenantPlan.fromJson(json['plan']),
      settings: json['settings'] ?? {},
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }
  
  /// Converte o Tenant para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan': plan.toJson(),
      'settings': settings,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

/// Modelo que representa um plano de tenant
class TenantPlan {
  TenantPlan({
    required this.id,
    required this.name,
    required this.features,
    this.maxUsers = 1,
    this.maxAppointments = 100,
  });

  final String id;
  final String name;
  final List<String> features;
  final int maxUsers;
  final int maxAppointments;
  
  /// Cria um TenantPlan a partir de um mapa JSON
  factory TenantPlan.fromJson(Map<String, dynamic> json) {
    return TenantPlan(
      id: json['id'],
      name: json['name'],
      features: List<String>.from(json['features'] ?? []),
      maxUsers: json['maxUsers'] ?? 1,
      maxAppointments: json['maxAppointments'] ?? 100,
    );
  }
  
  /// Converte o TenantPlan para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'features': features,
      'maxUsers': maxUsers,
      'maxAppointments': maxAppointments,
    };
  }
}

/// Modelo que representa um usuário no sistema
class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.tenantId,
    this.settings = const {},
    this.createdAt,
    this.lastLogin,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? tenantId;
  final Map<String, dynamic> settings;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  
  /// Verifica se o usuário é um administrador
  bool get isAdmin => role == UserRole.admin;
  
  /// Cria um User a partir de um mapa JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: _parseUserRole(json['role']),
      tenantId: json['tenantId'],
      settings: json['settings'] ?? {},
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
    );
  }
  
  /// Converte o User para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'tenantId': tenantId,
      'settings': settings,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
  
  /// Converte uma string em UserRole
  static UserRole _parseUserRole(String? roleStr) {
    if (roleStr == null) return UserRole.user;
    
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      default:
        return UserRole.user;
    }
  }
}

/// Enum que representa os papéis de usuário
enum UserRole {
  admin,
  manager,
  user,
}