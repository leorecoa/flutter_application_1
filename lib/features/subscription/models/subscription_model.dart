class SubscriptionModel {
  final String plan;
  final String status;
  final SubscriptionLimits limits;
  final double price;
  final DateTime startDate;
  final DateTime expirationDate;
  final String? paymentProvider;
  final String? paymentId;
  final String paymentStatus;

  SubscriptionModel({
    required this.plan,
    required this.status,
    required this.limits,
    required this.price,
    required this.startDate,
    required this.expirationDate,
    required this.paymentStatus,
    this.paymentProvider,
    this.paymentId,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'],
      status: json['status'],
      limits: SubscriptionLimits.fromJson(json['limits']),
      price: (json['price'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      expirationDate: DateTime.parse(json['expirationDate']),
      paymentProvider: json['paymentProvider'],
      paymentId: json['paymentId'],
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'limits': limits.toJson(),
      'price': price,
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'paymentProvider': paymentProvider,
      'paymentId': paymentId,
      'paymentStatus': paymentStatus,
    };
  }

  bool get isActive => status == 'ACTIVE';
  bool get isExpired => DateTime.now().isAfter(expirationDate);
  int get daysUntilExpiration =>
      expirationDate.difference(DateTime.now()).inDays;
}

class SubscriptionLimits {
  final int clients;
  final int barbers;
  final int appointments;

  SubscriptionLimits({
    required this.clients,
    required this.barbers,
    required this.appointments,
  });

  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) {
    return SubscriptionLimits(
      clients: json['clients'],
      barbers: json['barbers'],
      appointments: json['appointments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clients': clients,
      'barbers': barbers,
      'appointments': appointments,
    };
  }

  bool get hasUnlimitedClients => clients == -1;
  bool get hasUnlimitedBarbers => barbers == -1;
  bool get hasUnlimitedAppointments => appointments == -1;
}

class PlanModel {
  final String name;
  final double price;
  final SubscriptionLimits limits;
  final List<String> features;
  final bool isPopular;

  PlanModel({
    required this.name,
    required this.price,
    required this.limits,
    required this.features,
    this.isPopular = false,
  });

  static List<PlanModel> getAvailablePlans() {
    return [
      PlanModel(
        name: 'FREE',
        price: 0,
        limits: SubscriptionLimits(clients: 5, barbers: 1, appointments: 50),
        features: [
          'Até 5 clientes',
          '1 profissional',
          '50 agendamentos/mês',
          'Suporte básico'
        ],
      ),
      PlanModel(
        name: 'PRO',
        price: 29.90,
        limits:
            SubscriptionLimits(clients: 500, barbers: 5, appointments: 1000),
        features: [
          'Até 500 clientes',
          '5 profissionais',
          '1000 agendamentos/mês',
          'Relatórios avançados',
          'WhatsApp integrado',
          'Suporte prioritário'
        ],
        isPopular: true,
      ),
      PlanModel(
        name: 'PREMIUM',
        price: 59.90,
        limits: SubscriptionLimits(clients: -1, barbers: -1, appointments: -1),
        features: [
          'Clientes ilimitados',
          'Profissionais ilimitados',
          'Agendamentos ilimitados',
          'Multi-localização',
          'API personalizada',
          'Suporte 24/7'
        ],
      ),
    ];
  }
}
