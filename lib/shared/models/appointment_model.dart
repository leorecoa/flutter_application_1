class AppointmentModel {
  final String id;
  final String userId;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final String? paymentId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.clientEmail,
    this.paymentId,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['appointmentId'],
      userId: json['userId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      clientEmail: json['clientEmail'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      servicePrice: json['servicePrice'].toDouble(),
      appointmentDate: DateTime.parse(json['appointmentDate']),
      appointmentTime: json['appointmentTime'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
      ),
      paymentId: json['paymentId'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': id,
      'userId': userId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
      'appointmentTime': appointmentTime,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'paymentId': paymentId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}

enum PaymentMethod {
  pix,
  card,
  cash,
}
