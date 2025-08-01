/// Status de agendamento
enum AppointmentStatus { scheduled, confirmed, completed, cancelled }

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

  /// Nome do serviço
  final String serviceName;

  /// Preço do serviço
  final double price;

  /// Status do agendamento
  final AppointmentStatus status;

  /// Duração do serviço
  final Duration? duration;

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
  Appointment({
    required this.id,
    required this.professionalId,
    required this.serviceId,
    required this.dateTime,
    required this.clientName,
    required this.clientPhone,
    required this.serviceName,
    required this.price,
    this.status = AppointmentStatus.scheduled,
    this.duration,
    this.notes,
    this.clientId,
    required this.confirmedByClient,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Método copyWith para criar uma cópia modificada
  Appointment copyWith({
    String? id,
    String? professionalId,
    String? serviceId,
    DateTime? dateTime,
    String? clientName,
    String? clientPhone,
    String? serviceName,
    double? price,
    AppointmentStatus? status,
    Duration? duration,
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
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      clientId: clientId ?? this.clientId,
      confirmedByClient: confirmedByClient ?? this.confirmedByClient,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
