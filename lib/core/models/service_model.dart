import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;

  Service({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
  });

  factory Service.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Service(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      durationInMinutes: data['durationInMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'durationInMinutes': durationInMinutes,
    };
  }
}
