import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/api_service.dart';
import 'package:flutter_application_1/core/services/storage_service.dart';
import 'package:flutter_application_1/core/analytics/analytics_service.dart';

/// Provider para o serviço de API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider para o serviço de armazenamento
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider para o serviço de analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});