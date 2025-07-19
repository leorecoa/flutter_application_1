import 'package:flutter/foundation.dart';

/// Modelo para representar uma ação de notificação
@immutable
class NotificationAction {
  /// ID da notificação
  final String notificationId;
  
  /// ID do agendamento relacionado
  final String appointmentId;
  
  /// Tipo de ação (confirmar, cancelar, etc.)
  final String actionType;
  
  /// Dados adicionais da ação
  final Map<String, dynamic>? data;
  
  /// Construtor
  const NotificationAction({
    required this.notificationId,
    required this.appointmentId,
    required this.actionType,
    this.data,
  });
  
  /// Cria uma instância a partir de um mapa JSON
  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      notificationId: json['notificationId'] as String,
      appointmentId: json['appointmentId'] as String,
      actionType: json['actionType'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
  
  /// Converte a instância para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'appointmentId': appointmentId,
      'actionType': actionType,
      'data': data,
    };
  }
  
  /// Cria uma cópia com alguns campos alterados
  NotificationAction copyWith({
    String? notificationId,
    String? appointmentId,
    String? actionType,
    Map<String, dynamic>? data,
  }) {
    return NotificationAction(
      notificationId: notificationId ?? this.notificationId,
      appointmentId: appointmentId ?? this.appointmentId,
      actionType: actionType ?? this.actionType,
      data: data ?? this.data,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is NotificationAction &&
        other.notificationId == notificationId &&
        other.appointmentId == appointmentId &&
        other.actionType == actionType;
  }
  
  @override
  int get hashCode => notificationId.hashCode ^ appointmentId.hashCode ^ actionType.hashCode;
}