class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxClients;
  final int maxAppointments;
  final bool hasAnalytics;
  final bool hasNotifications;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxClients,
    required this.maxAppointments,
    required this.hasAnalytics,
    required this.hasNotifications,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      maxClients: json['maxClients'] ?? 0,
      maxAppointments: json['maxAppointments'] ?? 0,
      hasAnalytics: json['hasAnalytics'] ?? false,
      hasNotifications: json['hasNotifications'] ?? false,
      isPopular: json['isPopular'] ?? false,
    );
  }

  static List<SubscriptionPlan> getDefaultPlans() {
    return [
      const SubscriptionPlan(
        id: 'starter',
        name: 'Starter',
        description: 'Perfeito para começar',
        monthlyPrice: 29.90,
        yearlyPrice: 299.00,
        maxClients: 50,
        maxAppointments: 100,
        hasAnalytics: false,
        hasNotifications: false,
        features: [
          'Até 50 clientes',
          'Até 100 agendamentos/mês',
          'Dashboard básico',
          'Suporte por email',
        ],
      ),
      const SubscriptionPlan(
        id: 'professional',
        name: 'Professional',
        description: 'Para negócios em crescimento',
        monthlyPrice: 59.90,
        yearlyPrice: 599.00,
        maxClients: 200,
        maxAppointments: 500,
        hasAnalytics: true,
        hasNotifications: true,
        isPopular: true,
        features: [
          'Até 200 clientes',
          'Até 500 agendamentos/mês',
          'Analytics avançado',
          'Notificações automáticas',
          'Relatórios detalhados',
          'Suporte prioritário',
        ],
      ),
      const SubscriptionPlan(
        id: 'enterprise',
        name: 'Enterprise',
        description: 'Para grandes empresas',
        monthlyPrice: 99.90,
        yearlyPrice: 999.00,
        maxClients: -1,
        maxAppointments: -1,
        hasAnalytics: true,
        hasNotifications: true,
        features: [
          'Clientes ilimitados',
          'Agendamentos ilimitados',
          'Analytics completo',
          'Notificações personalizadas',
          'API personalizada',
          'Suporte 24/7',
          'Treinamento incluído',
        ],
      ),
    ];
  }
}

class UserSubscription {
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String status;
  final double amountPaid;

  const UserSubscription({
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.status,
    required this.amountPaid,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      planId: json['planId'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? '',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
    );
  }
}