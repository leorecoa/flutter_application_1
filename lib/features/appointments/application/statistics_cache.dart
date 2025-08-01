import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';

/// Classe para armazenar estatísticas em cache com TTL
class StatisticsCache {
  final int ttlMinutes;
  DateTime? _lastUpdated;
  Map<String, dynamic>? _cachedStats;

  StatisticsCache({this.ttlMinutes = 15});

  /// Verifica se o cache está válido
  bool get isValid {
    if (_lastUpdated == null || _cachedStats == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!).inMinutes;

    return difference < ttlMinutes;
  }

  /// Obtém as estatísticas do cache ou calcula novas
  Map<String, dynamic> getStatistics(List<Appointment> appointments) {
    if (isValid) {
      return _cachedStats!;
    }

    // Calcular novas estatísticas
    final stats = _calculateStatistics(appointments);

    // Atualizar cache
    _cachedStats = stats;
    _lastUpdated = DateTime.now();

    return stats;
  }

  /// Calcula estatísticas a partir dos agendamentos
  Map<String, dynamic> _calculateStatistics(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return {
        'totalAppointments': 0,
        'confirmedRate': 0.0,
        'totalRevenue': 0.0,
        'averagePrice': 0.0,
        'statusDistribution': <String, int>{},
      };
    }

    // Total de agendamentos
    final totalAppointments = appointments.length;

    // Contagem por status
    final statusCount = <AppointmentStatus, int>{};
    for (final appointment in appointments) {
      statusCount[appointment.status] =
          (statusCount[appointment.status] ?? 0) + 1;
    }

    // Taxa de confirmação
    final confirmed = statusCount[AppointmentStatus.confirmed] ?? 0;
    final scheduled = statusCount[AppointmentStatus.scheduled] ?? 0;
    final confirmedRate = scheduled + confirmed > 0
        ? confirmed / (scheduled + confirmed) * 100
        : 0.0;

    // Receita total
    double totalRevenue = 0;
    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.completed) {
        totalRevenue += appointment.price;
      }
    }

    // Preço médio
    final averagePrice = appointments.isNotEmpty
        ? appointments.map((a) => a.price).reduce((a, b) => a + b) /
              appointments.length
        : 0.0;

    // Distribuição por status para exibição
    final statusDistribution = <String, int>{};
    for (final entry in statusCount.entries) {
      statusDistribution[_getStatusName(entry.key)] = entry.value;
    }

    return {
      'totalAppointments': totalAppointments,
      'confirmedRate': confirmedRate,
      'totalRevenue': totalRevenue,
      'averagePrice': averagePrice,
      'statusDistribution': statusDistribution,
    };
  }

  /// Converte status para nome legível
  String _getStatusName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Não Compareceu';
      default:
        return 'Desconhecido';
    }
  }

  /// Força a atualização do cache
  void invalidate() {
    _cachedStats = null;
    _lastUpdated = null;
  }
}

/// Provider para o cache de estatísticas
final statisticsCacheProvider = Provider<StatisticsCache>((ref) {
  return StatisticsCache();
});

/// Provider para estatísticas com cache
final cachedStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final appointments = ref.watch(allAppointmentsProvider).valueOrNull ?? [];
  final cache = ref.watch(statisticsCacheProvider);

  return cache.getStatistics(appointments);
});
