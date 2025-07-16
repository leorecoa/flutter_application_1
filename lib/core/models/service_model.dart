class Service {
  final String id;
  final String name;
  final int duration; // Duração em minutos
  final double price;
  final String? description;

  const Service({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.description,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
        'price': price,
        'description': description,
      };

  Service copyWith({
    String? id,
    String? name,
    int? duration,
    double? price,
    String? description,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}