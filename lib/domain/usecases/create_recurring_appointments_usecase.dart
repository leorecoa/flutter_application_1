import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/logging/logger.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';

/// Caso de uso para criar agendamentos recorrentes
class CreateRecurringAppointmentsUseCase {
  final AppointmentRepository _repository;

  /// Construtor
  CreateRecurringAppointmentsUseCase(this._repository);

  /// Executa o caso de uso
  Future<List<Appointment>> execute(List<Appointment> appointments) async {
    try {
      // Validação básica
      if (appointments.isEmpty) {
        throw ValidationException('Lista de agendamentos vazia');
      }

      // Valida cada agendamento
      for (final appointment in appointments) {
        if (appointment.clientName.isEmpty) {
          throw ValidationException('Nome do cliente é obrigatório');
        }

        if (appointment.serviceName.isEmpty) {
          throw ValidationException('Nome do serviço é obrigatório');
        }

        // Verifica se a data/hora é válida
        final now = DateTime.now();
        if (appointment.date.isBefore(now) && appointment.date.day != now.day) {
          throw ValidationException(
            'Não é possível agendar para datas passadas',
          );
        }
      }

      // Cria os agendamentos recorrentes
      final createdAppointments = await _repository.createRecurringAppointments(
        appointments,
      );

      Logger.info(
        'Agendamentos recorrentes criados com sucesso',
        context: {'count': createdAppointments.length},
      );

      return createdAppointments;
    } on ValidationException catch (e) {
      Logger.error(
        'Erro de validação ao criar agendamentos recorrentes',
        error: e,
      );
      rethrow;
    } catch (e) {
      Logger.error('Erro ao criar agendamentos recorrentes', error: e);
      throw UseCaseException('Erro ao criar agendamentos recorrentes: $e');
    }
  }
}
