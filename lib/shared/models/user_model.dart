class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String businessName;
  final String businessType;
  final String customLink;
  final String planId;
  final DateTime planExpiry;
  final bool isActive;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.businessType,
    required this.customLink,
    required this.planId,
    required this.planExpiry,
    required this.isActive,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      businessName: json['businessName'],
      businessType: json['businessType'],
      customLink: json['customLink'],
      planId: json['planId'],
      planExpiry: DateTime.parse(json['planExpiry']),
      isActive: json['isActive'],
      settings: UserSettings.fromJson(json['settings']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      'name': name,
      'phone': phone,
      'businessName': businessName,
      'businessType': businessType,
      'customLink': customLink,
      'planId': planId,
      'planExpiry': planExpiry.toIso8601String(),
      'isActive': isActive,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserSettings {
  final bool whatsappEnabled;
  final String whatsappNumber;
  final List<String> paymentMethods;
  final Map<String, WorkingHours> workingHours;

  UserSettings({
    required this.whatsappEnabled,
    required this.whatsappNumber,
    required this.paymentMethods,
    required this.workingHours,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      whatsappEnabled: json['whatsappEnabled'],
      whatsappNumber: json['whatsappNumber'],
      paymentMethods: List<String>.from(json['paymentMethods']),
      workingHours: Map<String, WorkingHours>.from(
        json['workingHours'].map(
          (key, value) => MapEntry(key, WorkingHours.fromJson(value)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsappEnabled': whatsappEnabled,
      'whatsappNumber': whatsappNumber,
      'paymentMethods': paymentMethods,
      'workingHours': workingHours.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

class WorkingHours {
  final String start;
  final String end;
  final bool enabled;

  WorkingHours({
    required this.start,
    required this.end,
    required this.enabled,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      start: json['start'],
      end: json['end'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'enabled': enabled,
    };
  }
}