import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../core/models/appointment_model.dart';

/// Implementação local do AppointmentRepository usando SharedPreferences
class LocalAppointmentRepository implements AppointmentRepository {
  static const String _appointmentsKey = 'local_appointments';
  static const String _appointmentCounterKey = 'appointment_counter';

  /// Busca agendamentos com paginação e filtros
  @override
  Future<List<dynamic>> getAppointments({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      // Converte JSON para objetos Appointment
      List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      // Aplica filtros se fornecidos
      if (filters != null) {
        appointments = _applyFilters(appointments, filters);
      }

      // Aplica paginação
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;

      if (startIndex >= appointments.length) {
        return [];
      }

      final paginatedAppointments = appointments.sublist(
        startIndex,
        endIndex > appointments.length ? appointments.length : endIndex,
      );

      return paginatedAppointments;
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  /// Atualiza um agendamento existente
  @override
  Future<dynamic> updateAppointment(dynamic appointment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      // Encontra e atualiza o agendamento
      final appointmentToUpdate = appointment as Appointment;
      final index = appointments.indexWhere(
        (a) => a.id == appointmentToUpdate.id,
      );

      if (index == -1) {
        throw Exception('Agendamento não encontrado');
      }

      appointments[index] = appointmentToUpdate;

      // Salva a lista atualizada
      await _saveAppointments(appointments);

      return appointmentToUpdate;
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento: $e');
    }
  }

  /// Atualiza o status de um agendamento
  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      final index = appointments.indexWhere((a) => a.id == appointmentId);

      if (index == -1) {
        throw Exception('Agendamento não encontrado');
      }

      // Converte string para AppointmentStatus
      final status = _stringToAppointmentStatus(newStatus);

      // Atualiza o status
      appointments[index] = appointments[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _saveAppointments(appointments);
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  /// Exclui um agendamento
  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      appointments.removeWhere((a) => a.id == appointmentId);

      await _saveAppointments(appointments);
    } catch (e) {
      throw Exception('Erro ao excluir agendamento: $e');
    }
  }

  /// Cria múltiplos agendamentos recorrentes
  @override
  Future<List<dynamic>> createRecurringAppointments(
    List<dynamic> appointments,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> existingAppointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      // Gera IDs únicos para os novos agendamentos
      final newAppointments = <Appointment>[];
      for (final appointment in appointments) {
        final appt = appointment as Appointment;
        final newId = await _generateUniqueId();
        newAppointments.add(appt.copyWith(id: newId));
      }

      // Adiciona os novos agendamentos
      existingAppointments.addAll(newAppointments);

      await _saveAppointments(existingAppointments);

      return newAppointments;
    } catch (e) {
      throw Exception('Erro ao criar agendamentos recorrentes: $e');
    }
  }

  /// Exporta agendamentos para o formato especificado
  @override
  Future<String> exportAppointments({required String format}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      switch (format.toLowerCase()) {
        case 'csv':
          return _exportToCsv(appointments);
        case 'json':
          return _exportToJson(appointments);
        default:
          throw Exception('Formato não suportado: $format');
      }
    } catch (e) {
      throw Exception('Erro ao exportar agendamentos: $e');
    }
  }

  /// Cria um novo agendamento
  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      // Gera ID único
      final newId = await _generateUniqueId();
      final newAppointment = appointment.copyWith(id: newId);
      appointments.add(newAppointment);

      await _saveAppointments(appointments);

      return newAppointment;
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  /// Busca agendamentos por data
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

      final List<Appointment> appointments = appointmentsJson
          .map((json) => _appointmentFromJson(jsonDecode(json)))
          .toList();

      return appointments.where((appointment) {
        final appointmentDate = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );
        final searchDate = DateTime(date.year, date.month, date.day);
        return appointmentDate.isAtSameMomentAs(searchDate);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos por data: $e');
    }
  }

  /// Aplica filtros aos agendamentos
  List<Appointment> _applyFilters(
    List<Appointment> appointments,
    Map<String, dynamic> filters,
  ) {
    List<Appointment> filtered = appointments;

    // Filtro por status
    if (filters.containsKey('status')) {
      final status = filters['status'] as String;
      if (status.isNotEmpty && status != 'all') {
        final appointmentStatus = _stringToAppointmentStatus(status);
        filtered =
            filtered.where((a) => a.status == appointmentStatus).toList();
      }
    }

    // Filtro por cliente
    if (filters.containsKey('clientName')) {
      final clientName = filters['clientName'] as String;
      if (clientName.isNotEmpty) {
        filtered = filtered
            .where(
              (a) =>
                  a.clientName.toLowerCase().contains(clientName.toLowerCase()),
            )
            .toList();
      }
    }

    // Filtro por data
    if (filters.containsKey('date')) {
      final date = filters['date'] as DateTime;
      filtered = filtered.where((a) {
        final appointmentDate = DateTime(
          a.dateTime.year,
          a.dateTime.month,
          a.dateTime.day,
        );
        final searchDate = DateTime(date.year, date.month, date.day);
        return appointmentDate.isAtSameMomentAs(searchDate);
      }).toList();
    }

    // Ordenação
    if (filters.containsKey('sortBy')) {
      final sortBy = filters['sortBy'] as String;
      final sortOrder = filters['sortOrder'] as String? ?? 'asc';

      switch (sortBy) {
        case 'date':
          filtered.sort(
            (a, b) => sortOrder == 'asc'
                ? a.dateTime.compareTo(b.dateTime)
                : b.dateTime.compareTo(a.dateTime),
          );
          break;
        case 'clientName':
          filtered.sort(
            (a, b) => sortOrder == 'asc'
                ? a.clientName.compareTo(b.clientName)
                : b.clientName.compareTo(a.clientName),
          );
          break;
        case 'status':
          filtered.sort(
            (a, b) => sortOrder == 'asc'
                ? a.status.index.compareTo(b.status.index)
                : b.status.index.compareTo(a.status.index),
          );
          break;
      }
    }

    return filtered;
  }

  /// Salva a lista de agendamentos
  Future<void> _saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = appointments
        .map((appointment) => jsonEncode(_appointmentToJson(appointment)))
        .toList();

    await prefs.setStringList(_appointmentsKey, appointmentsJson);
  }

  /// Gera ID único para agendamentos
  Future<String> _generateUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt(_appointmentCounterKey) ?? 0;
    final newCounter = counter + 1;
    await prefs.setInt(_appointmentCounterKey, newCounter);
    return 'appointment_$newCounter';
  }

  /// Converte Appointment para JSON
  Map<String, dynamic> _appointmentToJson(Appointment appointment) {
    return {
      'id': appointment.id,
      'professionalId': appointment.professionalId,
      'serviceId': appointment.serviceId,
      'dateTime': appointment.dateTime.toIso8601String(),
      'clientName': appointment.clientName,
      'clientPhone': appointment.clientPhone,
      'serviceName': appointment.serviceName,
      'price': appointment.price,
      'status': appointment.status.index,
      'duration': appointment.duration?.inMinutes,
      'notes': appointment.notes,
      'clientId': appointment.clientId,
      'confirmedByClient': appointment.confirmedByClient,
      'createdAt': appointment.createdAt.toIso8601String(),
      'updatedAt': appointment.updatedAt.toIso8601String(),
    };
  }

  /// Converte JSON para Appointment
  Appointment _appointmentFromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      professionalId: json['professionalId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      serviceName: json['serviceName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: AppointmentStatus.values[json['status'] ?? 0],
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      notes: json['notes'],
      clientId: json['clientId'],
      confirmedByClient: json['confirmedByClient'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Converte string para AppointmentStatus
  AppointmentStatus _stringToAppointmentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.scheduled;
    }
  }

  /// Exporta para CSV
  String _exportToCsv(List<Appointment> appointments) {
    final csv = StringBuffer();
    csv.writeln('ID,Cliente,Serviço,Data,Hora,Status,Preço');

    for (final appointment in appointments) {
      csv.writeln(
        '${appointment.id},${appointment.clientName},${appointment.serviceName},'
        '${appointment.dateTime.toIso8601String()},${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')},'
        '${appointment.status.name},${appointment.price}',
      );
    }

    return csv.toString();
  }

  /// Exporta para JSON
  String _exportToJson(List<Appointment> appointments) {
    final appointmentsJson =
        appointments.map((a) => _appointmentToJson(a)).toList();
    return jsonEncode(appointmentsJson);
  }

  /// Inicializa dados de exemplo se não existirem
  Future<void> initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getStringList(_appointmentsKey);

    if (appointmentsJson == null || appointmentsJson.isEmpty) {
      final now = DateTime.now();
      final sampleAppointments = [
        Appointment(
          id: 'appointment_1',
          professionalId: 'prof_1',
          serviceId: 'service_1',
          dateTime: now.add(const Duration(days: 1, hours: 10)),
          clientName: 'João Silva',
          clientPhone: '(11) 99999-9999',
          serviceName: 'Corte Masculino',
          price: 30.0,
          status: AppointmentStatus.confirmed,
          duration: const Duration(minutes: 60),
          notes: 'Cliente preferência por corte tradicional',
          clientId: 'client_1',
          confirmedByClient: true,
          createdAt: now,
          updatedAt: now,
        ),
        Appointment(
          id: 'appointment_2',
          professionalId: 'prof_1',
          serviceId: 'service_2',
          dateTime: now.add(const Duration(days: 2, hours: 14)),
          clientName: 'Maria Santos',
          clientPhone: '(11) 88888-8888',
          serviceName: 'Manicure',
          price: 25.0,
          status: AppointmentStatus.scheduled,
          duration: const Duration(minutes: 90),
          notes: 'Primeira visita',
          clientId: 'client_2',
          confirmedByClient: false,
          createdAt: now,
          updatedAt: now,
        ),
        Appointment(
          id: 'appointment_3',
          professionalId: 'prof_1',
          serviceId: 'service_3',
          dateTime: now.add(const Duration(days: 3, hours: 16)),
          clientName: 'Pedro Costa',
          clientPhone: '(11) 77777-7777',
          serviceName: 'Barba',
          price: 15.0,
          status: AppointmentStatus.confirmed,
          duration: const Duration(minutes: 30),
          notes: 'Manter estilo atual',
          clientId: 'client_3',
          confirmedByClient: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await _saveAppointments(sampleAppointments);
    }
  }
}
