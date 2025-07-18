import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/notification_history_model.dart';

/// Serviço para gerenciar o histórico de notificações
class NotificationHistoryService {
  static const String _storageKey = 'notification_history';
  
  /// Salva uma notificação no histórico
  Future<void> saveNotification({
    required String title,
    required String body,
    String? appointmentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getNotificationHistory();
      
      // Criar nova notificação
      final notification = NotificationHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        appointmentId: appointmentId,
      );
      
      // Adicionar ao histórico
      history.insert(0, notification);
      
      // Limitar o histórico a 50 notificações
      if (history.length > 50) {
        history.removeLast();
      }
      
      // Salvar no SharedPreferences
      await prefs.setString(_storageKey, jsonEncode(
        history.map((item) => item.toJson()).toList(),
      ));
      
      debugPrint('Notificação salva no histórico: $title');
    } catch (e) {
      debugPrint('Erro ao salvar notificação no histórico: $e');
    }
  }
  
  /// Obtém o histórico de notificações
  Future<List<NotificationHistoryItem>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_storageKey);
      
      if (historyJson == null) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded
          .map((item) => NotificationHistoryItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter histórico de notificações: $e');
      return [];
    }
  }
  
  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getNotificationHistory();
      
      final index = history.indexWhere((item) => item.id == notificationId);
      if (index != -1) {
        history[index] = history[index].copyWith(isRead: true);
        
        await prefs.setString(_storageKey, jsonEncode(
          history.map((item) => item.toJson()).toList(),
        ));
      }
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
    }
  }
  
  /// Limpa o histórico de notificações
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Erro ao limpar histórico de notificações: $e');
    }
  }
}

/// Provider para o serviço de histórico de notificações
final notificationHistoryServiceProvider = Provider<NotificationHistoryService>((ref) {
  return NotificationHistoryService();
});

/// Provider para o histórico de notificações
final notificationHistoryProvider = FutureProvider<List<NotificationHistoryItem>>((ref) async {
  final service = ref.watch(notificationHistoryServiceProvider);
  return await service.getNotificationHistory();
});