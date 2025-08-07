import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/data/repositories/appointment_repository_provider.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';
import 'appointments_state.dart';

final appointmentsScreenControllerProvider =
    StateNotifierProvider<AppointmentsScreenController, AppointmentsState>((ref) {
  final appointmentRepository = ref.watch(appointmentRepositoryProvider);
  // TODO: Substituir por um provider que forneça o ID do tenant logado
  const tenantId = 'mock-tenant-id';
  return AppointmentsScreenController(appointmentRepository, tenantId);
});

class AppointmentsScreenController extends StateNotifier<AppointmentsState> {
  final AppointmentRepository _repository;
  final String _tenantId;

  AppointmentsScreenController(this._repository, this._tenantId)
      : super(AppointmentsState(
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
        )) {
    fetchAppointmentsForMonth(state.focusedDay);
  }

  Future<void> fetchAppointmentsForMonth(DateTime month) async {
    state = state.copyWith(appointmentsForSelectedDay: const AsyncValue.loading());
    try {
      final firstDay = DateTime(month.year, month.month);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final appointments = await _repository.getAppointments(
        tenantId: _tenantId,
        pageSize: 1000, // Buscar um número grande para o mês todo
        filters: {
          'startDate': firstDay.toIso8601String().split('T')[0],
          'endDate': lastDay.toIso8601String().split('T')[0],
        },
      );

      final events = groupBy<Appointment, DateTime>(
        appointments,
        (appointment) => DateTime.utc(
            appointment.date.year, appointment.date.month, appointment.date.day),
      );

      state = state.copyWith(
        events: events,
        // Também atualiza a lista para o dia atualmente selecionado
        appointmentsForSelectedDay: AsyncValue.data(
            events[DateTime.utc(state.selectedDay.year, state.selectedDay.month,
                state.selectedDay.day)] ??
                []),
      );
    } catch (e, st) {
      state = state.copyWith(appointmentsForSelectedDay: AsyncValue.error(e, st));
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(state.selectedDay, selectedDay)) {
      final eventsForDay = state.events[DateTime.utc(
              selectedDay.year, selectedDay.month, selectedDay.day)] ??
          [];
      state = state.copyWith(
        selectedDay: selectedDay,
        focusedDay: focusedDay,
        appointmentsForSelectedDay: AsyncValue.data(eventsForDay),
      );
    }
  }

  void onFormatChanged(CalendarFormat format) {
    if (state.calendarFormat != format) {
      state = state.copyWith(calendarFormat: format);
    }
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
    fetchAppointmentsForMonth(focusedDay);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final updatedAppointment = await _repository.updateAppointmentStatus(
        tenantId: _tenantId,
        appointmentId: appointmentId,
        newStatus: 'Canceled',
      );
      _updateLocalState(updatedAppointment);
    } catch (e) {
      // Propaga o erro para que a UI possa tratá-lo
      rethrow;
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final updatedAppointment = await _repository.updateAppointment(
        tenantId: _tenantId,
        appointment: appointment,
      );
      _updateLocalState(updatedAppointment);
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza o estado local de forma otimizada após uma alteração em um agendamento.
  /// Este método remove o agendamento antigo (buscando por ID) e insere o novo,
  /// lidando corretamente com mudanças de data.
  void _updateLocalState(Appointment updatedAppointment) {
    final newEvents = Map<DateTime, List<Appointment>>.from(state.events);

    // 1. Itera sobre todos os dias no mapa de eventos para encontrar e remover a entrada antiga.
    // Isso é necessário para o caso de a data do agendamento ter sido alterada.
    newEvents.removeWhere((date, appointments) {
      appointments.removeWhere((a) => a.id == updatedAppointment.id);
      return appointments.isEmpty;
    });

    // 2. Adiciona o agendamento atualizado na lista do dia correto.
    final dayOfAppointment = DateTime.utc(updatedAppointment.date.year,
        updatedAppointment.date.month, updatedAppointment.date.day);

    final dayEvents = newEvents[dayOfAppointment] ?? [];
    dayEvents.add(updatedAppointment);
    dayEvents.sort((a, b) => a.date.compareTo(b.date)); // Mantém a lista ordenada por hora
    newEvents[dayOfAppointment] = dayEvents;

    // 3. Atualiza o estado do provider com o novo mapa de eventos.
    final selectedDayKey = DateTime.utc(
        state.selectedDay.year, state.selectedDay.month, state.selectedDay.day);

    state = state.copyWith(
        events: newEvents,
        // Atualiza a lista de agendamentos para o dia selecionado, caso seja o dia afetado.
        appointmentsForSelectedDay:
            AsyncValue.data(newEvents[selectedDayKey] ?? []));
  }
}
}