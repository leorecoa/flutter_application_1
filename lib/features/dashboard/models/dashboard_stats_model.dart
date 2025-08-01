import 'package:flutter/foundation.dart';

@immutable
class DashboardStats {
  final int totalAppointments;
  final int todayAppointments;
  final int confirmedAppointments;
  final int cancelledAppointments;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double todayRevenue;
  final double averageAppointmentValue;
  final double growthRate;
  final List<ChartData> weeklyData;
  final List<ChartData> monthlyData;

  const DashboardStats({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.confirmedAppointments,
    required this.cancelledAppointments,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.todayRevenue,
    required this.averageAppointmentValue,
    required this.growthRate,
    required this.weeklyData,
    required this.monthlyData,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalAppointments: json['totalAppointments'] ?? 0,
      todayAppointments: json['todayAppointments'] ?? 0,
      confirmedAppointments: json['confirmedAppointments'] ?? 0,
      cancelledAppointments: json['cancelledAppointments'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      weeklyRevenue: (json['weeklyRevenue'] ?? 0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      averageAppointmentValue: (json['averageAppointmentValue'] ?? 0)
          .toDouble(),
      growthRate: (json['growthRate'] ?? 0).toDouble(),
      weeklyData:
          (json['weeklyData'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      monthlyData:
          (json['monthlyData'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalAppointments: 0,
      todayAppointments: 0,
      confirmedAppointments: 0,
      cancelledAppointments: 0,
      monthlyRevenue: 0,
      weeklyRevenue: 0,
      todayRevenue: 0,
      averageAppointmentValue: 0,
      growthRate: 0,
      weeklyData: [],
      monthlyData: [],
    );
  }
}

@immutable
class ChartData {
  final String label;
  final double value;
  final DateTime date;

  const ChartData({
    required this.label,
    required this.value,
    required this.date,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
