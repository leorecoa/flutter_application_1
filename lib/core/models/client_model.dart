import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String? id;
  final String name;
  final String email;
  final String phoneNumber;

  Client({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory Client.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Client(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
