class User {
  final String id;
  final String email;
  final String name;
  final String? businessName;
  final String? phone;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.businessName,
    this.phone,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON não pode ser nulo');
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Usuário',
      businessName: json['businessName']?.toString(),
      phone: json['phone']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'businessName': businessName,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}