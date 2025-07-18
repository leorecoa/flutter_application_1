class Client {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      };

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}