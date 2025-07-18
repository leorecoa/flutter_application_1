/// Modelo para representar uma notificação no histórico
class NotificationHistoryItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? appointmentId;
  final bool isRead;
  
  const NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.appointmentId,
    this.isRead = false,
  });
  
  NotificationHistoryItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? appointmentId,
    bool? isRead,
  }) {
    return NotificationHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      appointmentId: appointmentId ?? this.appointmentId,
      isRead: isRead ?? this.isRead,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'appointmentId': appointmentId,
      'isRead': isRead,
    };
  }
  
  factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      appointmentId: json['appointmentId'],
      isRead: json['isRead'] ?? false,
    );
  }
}