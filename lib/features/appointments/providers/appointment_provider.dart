import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/appointment.dart';
import '../../../data/repositories/appointment_repository_impl.dart';
import '../domain/appointment_repository.dart';

/// Provider para o estado dos agendamentos
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      return AppointmentNotifier(ref.read(appointmentRepositoryProvider));
    });

/// Estado dos agendamentos
class AppointmentState {
  final bool isLoading;
  final List<Appointment> appointments;
  final String? error;
  final int currentPage;
  final bool hasMoreData;
  final Map<String, dynamic>? currentFilters;

  const AppointmentState({
    this.isLoading = false,
    this.appointments = const [],
    this.error,
    this.currentPage = 0,
    this.hasMoreData = true,
    this.currentFilters,
  });

  AppointmentState copyWith({
    bool? isLoading,
    List<Appointment>? appointments,
    String? error,
    int? currentPage,
    bool? hasMoreData,
    Map<String, dynamic>? currentFilters,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }
}

/// Notifier para gerenciar o estado dos agendamentos
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentNotifier(this._repository) : super(const AppointmentState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadAppointments();
  }

  /// Carrega agendamentos
  Future<void> loadAppointments({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointments = await _repository.getPaginatedAppointments(
        page: 0,
        pageSize: 20,
        filters: filters,
      );

      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
        currentPage: 0,
        hasMoreData: appointments.length == 20,
        currentFilters: filters,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar agendamentos: $e',
      );
    }
  }

  /// Carrega mais agendamentos (paginação)
  Future<void> loadMoreAppointments() async {
    if (state.isLoading || !state.hasMoreData) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final appointments = await _repository.getPaginatedAppointments(
        page: nextPage,
        pageSize: 20,
        filters: state.currentFilters,
      );

      if (appointments.isNotEmpty) {
        state = state.copyWith(
          appointments: [...state.appointments, ...appointments],
          currentPage: nextPage,
          hasMoreData: appointments.length == 20,
          isLoading: false,
        );
      } else {
        state = state.copyWith(hasMoreData: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar mais agendamentos: $e',
      );
    }
  }

  /// Cria um novo agendamento
  Future<bool> createAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newAppointment = await _repository.createAppointment(appointment);

      state = state.copyWith(
        appointments: [newAppointment, ...state.appointments],
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Atualiza um agendamento
  Future<bool> updateAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAppointment = await _repository.updateAppointment(
        appointment,
      );

      final updatedAppointments = state.appointments.map((a) {
        return a.id == appointment.id ? updatedAppointment : a;
      }).toList();

      state = state.copyWith(
        appointments: updatedAppointments,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Deleta um agendamento
  Future<bool> deleteAppointment(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteAppointment(id);

      final updatedAppointments = state.appointments
          .where((a) => a.id != id)
          .toList();

      state = state.copyWith(
        appointments: updatedAppointments,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Atualiza o status de um agendamento
  Future<bool> updateAppointmentStatus(
    String id,
    AppointmentStatus status,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAppointment = await _repository.updateAppointmentStatus(
        id,
        status,
      );

      final updatedAppointments = state.appointments.map((a) {
        return a.id == id ? updatedAppointment : a;
      }).toList();

      state = state.copyWith(
        appointments: updatedAppointments,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Atualiza a confirmação do cliente
  Future<bool> updateClientConfirmation(String id, bool isConfirmed) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAppointment = await _repository.updateClientConfirmation(
        id,
        isConfirmed,
      );

      final updatedAppointments = state.appointments.map((a) {
        return a.id == id ? updatedAppointment : a;
      }).toList();

      state = state.copyWith(
        appointments: updatedAppointments,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Cria múltiplos agendamentos
  Future<bool> createBatchAppointments(List<Appointment> appointments) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newAppointments = await _repository.createBatchAppointments(
        appointments,
      );

      state = state.copyWith(
        appointments: [...newAppointments, ...state.appointments],
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Atualiza o status de múltiplos agendamentos
  Future<bool> updateBatchStatus(
    List<String> ids,
    AppointmentStatus status,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAppointments = await _repository.updateBatchStatus(
        ids,
        status,
      );

      final appointmentMap = <String, Appointment>{};
      for (final appointment in updatedAppointments) {
        appointmentMap[appointment.id] = appointment;
      }

      final newAppointments = state.appointments.map((a) {
        return appointmentMap[a.id] ?? a;
      }).toList();

      state = state.copyWith(appointments: newAppointments, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Filtra agendamentos por data
  List<Appointment> getAppointmentsByDate(DateTime date) {
    return state.appointments.where((appointment) {
      return appointment.dateTime.year == date.year &&
          appointment.dateTime.month == date.month &&
          appointment.dateTime.day == date.day;
    }).toList();
  }

  /// Filtra agendamentos por status
  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return state.appointments.where((appointment) {
      return appointment.status == status;
    }).toList();
  }

  /// Filtra agendamentos por profissional
  List<Appointment> getAppointmentsByProfessional(String professionalId) {
    return state.appointments.where((appointment) {
      return appointment.professionalId == professionalId;
    }).toList();
  }

  /// Obtém agendamentos de hoje
  List<Appointment> get getTodayAppointments {
    return state.appointments
        .where((appointment) => appointment.isToday)
        .toList();
  }

  /// Obtém agendamentos desta semana
  List<Appointment> get getThisWeekAppointments {
    return state.appointments
        .where((appointment) => appointment.isThisWeek)
        .toList();
  }

  /// Obtém agendamentos pendentes
  List<Appointment> get getPendingAppointments {
    return state.appointments
        .where(
          (appointment) =>
              appointment.status == AppointmentStatus.scheduled ||
              appointment.status == AppointmentStatus.confirmed,
        )
        .toList();
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresca os dados
  Future<void> refresh() async {
    await loadAppointments(filters: state.currentFilters);
  }
}
