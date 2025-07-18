import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';
import 'appointments_service_v2.dart';

/// Serviço para gerenciar ações de notificações
class NotificationActionService {
  final AppointmentsServiceV2 _appointmentsService;
  final NotificationService _notificationService;
  StreamSubscription? _actionSubscription;
  
  NotificationActionService({
    required AppointmentsServiceV2 appointmentsService,
    required NotificationService notificationService,
  }) : _appointmentsService = appointmentsService,
       _notificationService = notificationService;
  
  void initialize() {
    // Inscrever-se no stream de ações de notificações
    _actionSubscription = _notificationService.actionStream.listen(_handleNotificationAction);
  }
  
  Future<void> _handleNotificationAction(NotificationAction action) async {
    debugPrint('Recebida ação de notificação: ${action.actionType} para agendamento ${action.appointmentId}');
    
    try {
      if (action.actionType == NotificationService.confirmAction) {
        // Confirmar agendamento
        await _appointmentsService.updateAppointmentStatus(
          action.appointmentId, 
          'confirmado',
        );
        debugPrint('Agendamento ${action.appointmentId} confirmado com sucesso');
      } else if (action.actionType == NotificationService.cancelAction) {
        // Cancelar agendamento
        await _appointmentsService.updateAppointmentStatus(
          action.appointmentId, 
          'cancelado',
        );
        debugPrint('Agendamento ${action.appointmentId} cancelado com sucesso');
      }
    } catch (e) {
      debugPrint('Erro ao processar ação de notificação: $e');
    }
  }
  
  void dispose() {
    _actionSubscription?.cancel();
  }
}

/// Provider para o serviço de ações de notificações
final notificationActionServiceProvider = Provider<NotificationActionService>((ref) {
  final appointmentsService = AppointmentsServiceV2();
  final notificationService = ref.watch(notificationServiceProvider);
  
  final service = NotificationActionService(
    appointmentsService: appointmentsService,
    notificationService: notificationService,
  );
  
  // Inicializar o serviço
  service.initialize();
  
  // Garantir que o serviço seja descartado corretamente
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});