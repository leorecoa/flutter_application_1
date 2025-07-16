class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      clientName: json['clientName'] as String,
      serviceName: json['serviceName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'serviceName': serviceName,
        'startTime': startTime.toIso8601String(),
      };
}
