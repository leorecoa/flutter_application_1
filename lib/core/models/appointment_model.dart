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
  final int? duration;
  final String? clientId;
  final String? serviceId;

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
    this.duration,
    this.clientId,
    this.serviceId,
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

  factory Appointment.fromDynamoJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['appointmentId'] ?? '',
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      service: json['service'] ?? '',
      dateTime: DateTime.parse(json['appointmentDateTime'] ?? DateTime.now().toIso8601String()),
      price: (json['price'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] != null ? int.parse(json['duration'].toString()) : 60,
      clientId: json['clientId'],
      serviceId: json['serviceId'],
    );
  }

  static AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'pendente':
        return AppointmentStatus.scheduled;
      case 'confirmado':
        return AppointmentStatus.confirmed;
      case 'concluido':
        return AppointmentStatus.completed;
      case 'cancelado':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.scheduled;
    }
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
      'duration': duration,
      'clientId': clientId,
      'serviceId': serviceId,
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
    int? duration,
    String? clientId,
    String? serviceId,
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
      duration: duration ?? this.duration,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
    );
  }
}