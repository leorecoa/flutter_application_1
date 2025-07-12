enum AppointmentStatus { scheduled, confirmed, completed, cancelled }

class Appointment {
  final String id;
  final String clientName;
  final String clientPhone;
  final String service;
  final DateTime dateTime;
  final double price;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.service,
    required this.dateTime,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      service: json['service'],
      dateTime: DateTime.parse(json['dateTime']),
      price: json['price'].toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'service': service,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? service,
    DateTime? dateTime,
    double? price,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      service: service ?? this.service,
      dateTime: dateTime ?? this.dateTime,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}