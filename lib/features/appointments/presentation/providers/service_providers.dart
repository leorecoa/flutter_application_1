import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';

/// Provider para os serviços
final serviceProvidersModule = ProviderContainer();

/// Provider para o serviço de armazenamento
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl();
});

/// Provider para o serviço de notificação
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});