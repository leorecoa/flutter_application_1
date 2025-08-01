import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/appointment.dart';
import '../../features/appointments/domain/appointment_repository.dart';
import '../../core/logging/logger.dart';

/// Provider para o repositório de agendamentos
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl();
});

/// Implementação local do repositório de agendamentos
class AppointmentRepositoryImpl implements AppointmentRepository {
  static const String _appointmentsKey = 'appointments';
  late SharedPreferences _prefs;

  /// Inicializa o repositório
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.info('Repositório de agendamentos inicializado');
  }

  @override
  Future<List<Appointment>> getAllAppointments() async {
    await _ensureInitialized();
    return _getAppointments();
  }

  @override
  Future<List<Appointment>> getPaginatedAppointments({
    required int page,
    required int pageSize,
    Map<String, dynamic>? filters,
  }) async {
    await _ensureInitialized();
    final allAppointments = _getAppointments();

    // Aplica filtros se fornecidos
    List<Appointment> filteredAppointments = allAppointments;

    if (filters != null) {
      filteredAppointments = _applyFilters(allAppointments, filters);
    }

    // Ordena por data/hora
    filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Aplica paginação
    final startIndex = page * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= filteredAppointments.length) {
      return [];
    }

    return filteredAppointments.sublist(
      startIndex,
      endIndex > filteredAppointments.length
          ? filteredAppointments.length
          : endIndex,
    );
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    await _ensureInitialized();

    // Verifica conflitos de horário
    final conflicts = await _checkConflicts(appointment);
    if (conflicts.isNotEmpty) {
      throw AppointmentConflictException(
        'Existe conflito de horário com os seguintes agendamentos: ${conflicts.map((a) => '${a.clientName} - ${_formatDateTime(a.dateTime)}').join(', ')}',
        conflicts,
      );
    }

    final appointments = _getAppointments();
    appointments.add(appointment);
    _saveAppointments(appointments);

    Logger.info(
      'Agendamento criado com sucesso',
      context: {
        'appointmentId': appointment.id,
        'clientName': appointment.clientName,
        'dateTime': appointment.dateTime.toIso8601String(),
      },
    );

    return appointment;
  }

  @override
  Future<Appointment> updateAppointment(Appointment appointment) async {
    await _ensureInitialized();

    // Verifica conflitos de horário (excluindo o próprio agendamento)
    final conflicts = await _checkConflicts(
      appointment,
      excludeId: appointment.id,
    );
    if (conflicts.isNotEmpty) {
      throw AppointmentConflictException(
        'Existe conflito de horário com os seguintes agendamentos: ${conflicts.map((a) => '${a.clientName} - ${_formatDateTime(a.dateTime)}').join(', ')}',
        conflicts,
      );
    }

    final appointments = _getAppointments();
    final index = appointments.indexWhere((a) => a.id == appointment.id);

    if (index == -1) {
      throw AppointmentNotFoundException('Agendamento não encontrado');
    }

    appointments[index] = appointment.copyWith(updatedAt: DateTime.now());
    _saveAppointments(appointments);

    Logger.info(
      'Agendamento atualizado com sucesso',
      context: {
        'appointmentId': appointment.id,
        'clientName': appointment.clientName,
      },
    );

    return appointments[index];
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await _ensureInitialized();

    final appointments = _getAppointments();
    final index = appointments.indexWhere((a) => a.id == id);

    if (index == -1) {
      throw AppointmentNotFoundException('Agendamento não encontrado');
    }

    appointments.removeAt(index);
    _saveAppointments(appointments);

    Logger.info(
      'Agendamento deletado com sucesso',
      context: {'appointmentId': id},
    );
  }

  @override
  Future<Appointment> updateAppointmentStatus(
    String id,
    AppointmentStatus status,
  ) async {
    await _ensureInitialized();

    final appointments = _getAppointments();
    final index = appointments.indexWhere((a) => a.id == id);

    if (index == -1) {
      throw AppointmentNotFoundException('Agendamento não encontrado');
    }

    final appointment = appointments[index];
    final updatedAppointment = appointment.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    appointments[index] = updatedAppointment;
    _saveAppointments(appointments);

    Logger.info(
      'Status do agendamento atualizado',
      context: {'appointmentId': id, 'newStatus': status.name},
    );

    return updatedAppointment;
  }

  @override
  Future<Appointment> updateClientConfirmation(
    String id,
    bool isConfirmed,
  ) async {
    await _ensureInitialized();

    final appointments = _getAppointments();
    final index = appointments.indexWhere((a) => a.id == id);

    if (index == -1) {
      throw AppointmentNotFoundException('Agendamento não encontrado');
    }

    final appointment = appointments[index];
    final updatedAppointment = appointment.copyWith(
      confirmedByClient: isConfirmed,
      updatedAt: DateTime.now(),
    );

    appointments[index] = updatedAppointment;
    _saveAppointments(appointments);

    Logger.info(
      'Confirmação do cliente atualizada',
      context: {'appointmentId': id, 'confirmed': isConfirmed},
    );

    return updatedAppointment;
  }

  @override
  Future<List<Appointment>> createBatchAppointments(
    List<Appointment> appointments,
  ) async {
    await _ensureInitialized();

    final allAppointments = _getAppointments();
    final newAppointments = <Appointment>[];

    for (final appointment in appointments) {
      // Verifica conflitos para cada agendamento
      final conflicts = await _checkConflicts(appointment);
      if (conflicts.isNotEmpty) {
        throw AppointmentConflictException(
          'Existe conflito de horário para o agendamento de ${appointment.clientName}',
          conflicts,
        );
      }
      newAppointments.add(appointment);
    }

    allAppointments.addAll(newAppointments);
    _saveAppointments(allAppointments);

    Logger.info(
      'Lote de agendamentos criado com sucesso',
      context: {'count': newAppointments.length},
    );

    return newAppointments;
  }

  @override
  Future<List<Appointment>> updateBatchStatus(
    List<String> ids,
    AppointmentStatus status,
  ) async {
    await _ensureInitialized();

    final appointments = _getAppointments();
    final updatedAppointments = <Appointment>[];

    for (final id in ids) {
      final index = appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        final appointment = appointments[index];
        final updatedAppointment = appointment.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        appointments[index] = updatedAppointment;
        updatedAppointments.add(updatedAppointment);
      }
    }

    _saveAppointments(appointments);

    Logger.info(
      'Status de lote atualizado',
      context: {'count': updatedAppointments.length, 'newStatus': status.name},
    );

    return updatedAppointments;
  }

  // Métodos auxiliares

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  List<Appointment> _getAppointments() {
    final appointmentsData = _prefs.getString(_appointmentsKey);
    if (appointmentsData == null) return [];

    try {
      final appointmentsJson = json.decode(appointmentsData) as List;
      return appointmentsJson
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Erro ao carregar agendamentos', error: e);
      return [];
    }
  }

  void _saveAppointments(List<Appointment> appointments) {
    final appointmentsJson = appointments.map((a) => a.toJson()).toList();
    _prefs.setString(_appointmentsKey, json.encode(appointmentsJson));
  }

  List<Appointment> _applyFilters(
    List<Appointment> appointments,
    Map<String, dynamic> filters,
  ) {
    return appointments.where((appointment) {
      // Filtro por profissional
      if (filters.containsKey('professionalId')) {
        if (appointment.professionalId != filters['professionalId']) {
          return false;
        }
      }

      // Filtro por status
      if (filters.containsKey('status')) {
        if (appointment.status != filters['status']) {
          return false;
        }
      }

      // Filtro por data (início)
      if (filters.containsKey('startDate')) {
        final startDate = filters['startDate'] as DateTime;
        if (appointment.dateTime.isBefore(startDate)) {
          return false;
        }
      }

      // Filtro por data (fim)
      if (filters.containsKey('endDate')) {
        final endDate = filters['endDate'] as DateTime;
        if (appointment.dateTime.isAfter(endDate)) {
          return false;
        }
      }

      // Filtro por cliente
      if (filters.containsKey('clientName')) {
        final clientName = filters['clientName'] as String;
        if (!appointment.clientName.toLowerCase().contains(
          clientName.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<List<Appointment>> _checkConflicts(
    Appointment appointment, {
    String? excludeId,
  }) async {
    final appointments = _getAppointments();
    final conflicts = <Appointment>[];

    for (final existingAppointment in appointments) {
      // Pula o agendamento que está sendo editado
      if (excludeId != null && existingAppointment.id == excludeId) {
        continue;
      }

      // Pula agendamentos cancelados
      if (existingAppointment.status == AppointmentStatus.cancelled) {
        continue;
      }

      if (appointment.conflictsWith(existingAppointment)) {
        conflicts.add(existingAppointment);
      }
    }

    return conflicts;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Exceção para conflitos de agendamento
class AppointmentConflictException implements Exception {
  final String message;
  final List<Appointment> conflicts;

  AppointmentConflictException(this.message, this.conflicts);

  @override
  String toString() => message;
}

/// Exceção para agendamento não encontrado
class AppointmentNotFoundException implements Exception {
  final String message;

  AppointmentNotFoundException(this.message);

  @override
  String toString() => message;
}
