/// Status de agendamento
enum AppointmentStatus {
  scheduled('Agendado'),
  confirmed('Confirmado'),
  completed('Concluído'),
  cancelled('Cancelado'),
  noShow('Não Compareceu');

  const AppointmentStatus(this.label);
  final String label;
}

/// Classe para agendamento
class Appointment {
  /// ID único do agendamento
  final String id;

  /// ID do profissional
  final String professionalId;

  /// ID do serviço
  final String serviceId;

  /// Data e hora do agendamento
  final DateTime dateTime;

  /// Nome do cliente
  final String clientName;

  /// Telefone do cliente
  final String clientPhone;

  /// Email do cliente
  final String? clientEmail;

  /// Nome do serviço
  final String serviceName;

  /// Preço do serviço
  final double price;

  /// Status do agendamento
  final AppointmentStatus status;

  /// Duração do serviço em minutos
  final int durationMinutes;

  /// Notas adicionais
  final String? notes;

  /// ID do cliente
  final String? clientId;

  /// Indica se o cliente confirmou o agendamento
  final bool confirmedByClient;

  /// Data de criação
  final DateTime createdAt;

  /// Data de atualização
  final DateTime updatedAt;

  /// Construtor
  const Appointment({
    required this.id,
    required this.professionalId,
    required this.serviceId,
    required this.dateTime,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    required this.serviceName,
    required this.price,
    this.status = AppointmentStatus.scheduled,
    required this.durationMinutes,
    this.notes,
    this.clientId,
    this.confirmedByClient = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria um agendamento a partir de JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      serviceId: json['serviceId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      clientName: json['clientName'] as String,
      clientPhone: json['clientPhone'] as String,
      clientEmail: json['clientEmail'] as String?,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      durationMinutes: json['durationMinutes'] as int,
      notes: json['notes'] as String?,
      clientId: json['clientId'] as String?,
      confirmedByClient: json['confirmedByClient'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'serviceId': serviceId,
      'dateTime': dateTime.toIso8601String(),
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'serviceName': serviceName,
      'price': price,
      'status': status.name,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'clientId': clientId,
      'confirmedByClient': confirmedByClient,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Método copyWith para criar uma cópia modificada
  Appointment copyWith({
    String? id,
    String? professionalId,
    String? serviceId,
    DateTime? dateTime,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? serviceName,
    double? price,
    AppointmentStatus? status,
    int? durationMinutes,
    String? notes,
    String? clientId,
    bool? confirmedByClient,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      clientId: clientId ?? this.clientId,
      confirmedByClient: confirmedByClient ?? this.confirmedByClient,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Retorna a data de fim do agendamento
  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  /// Verifica se o agendamento está em conflito com outro
  bool conflictsWith(Appointment other) {
    // Se é o mesmo agendamento, não há conflito
    if (id == other.id) return false;

    // Se são profissionais diferentes, não há conflito
    if (professionalId != other.professionalId) return false;

    // Verifica se há sobreposição de horários
    return dateTime.isBefore(other.endTime) && endTime.isAfter(other.dateTime);
  }

  /// Verifica se o agendamento está no passado
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Verifica se o agendamento é hoje
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Verifica se o agendamento é esta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Verifica se o agendamento pode ser cancelado
  bool get canBeCancelled {
    return status == AppointmentStatus.scheduled ||
        status == AppointmentStatus.confirmed;
  }

  /// Verifica se o agendamento pode ser confirmado
  bool get canBeConfirmed {
    return status == AppointmentStatus.scheduled;
  }

  /// Verifica se o agendamento pode ser concluído
  bool get canBeCompleted {
    return status == AppointmentStatus.confirmed;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Appointment(id: $id, clientName: $clientName, dateTime: $dateTime, status: $status)';
  }
}
