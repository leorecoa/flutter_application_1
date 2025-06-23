class ServiceModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int duration;
  final double price;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.category,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['serviceId'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'] ?? '',
      duration: json['duration'],
      price: json['price'].toDouble(),
      category: json['category'] ?? 'general',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': id,
      'userId': userId,
      'name': name,
      'description': description,
      'duration': duration,
      'price': price,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2)}';
  String get formattedDuration => '${duration}min';
}