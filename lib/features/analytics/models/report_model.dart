enum ReportType {
  daily,
  weekly,
  monthly,
  custom,
}

enum ReportCategory {
  revenue,
  appointments,
  clients,
  services,
}

class ReportModel {
  final String id;
  final ReportType type;
  final ReportCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  ReportModel({
    required this.id,
    required this.type,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.generatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.daily,
      ),
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.revenue,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      data: json['data'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'data': data,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
