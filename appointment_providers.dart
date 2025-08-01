import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/amplify_service.dart';
import 'package:flutter_application_1/core/tenant/tenant_context.dart';
import 'package:flutter_application_1/data/repositories/appointment_repository_impl.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';
import 'service_providers.dart';

/// Provider para o repositório de agendamentos
final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(ref.watch(amplifyServiceProvider)),
);

/// Provider para o contexto do tenant
final tenantContextProvider = Provider<TenantContext>((ref) => TenantContext());

/// Provider para agendamentos paginados
final paginatedAppointmentsProvider =
    StateNotifierProvider<
      PaginatedAppointmentsNotifier,
      PaginatedAppointmentsState
    >((ref) => PaginatedAppointmentsNotifier(ref));

/// Estado para agendamentos paginados
class PaginatedAppointmentsState {
  final List<dynamic> appointments;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  PaginatedAppointmentsState({
    required this.appointments,
    required this.isLoading,
    this.error,
    required this.currentPage,
    required this.hasMorePages,
  });

  factory PaginatedAppointmentsState.initial() {
    return PaginatedAppointmentsState(
      appointments: [],
      isLoading: false,
      currentPage: 1,
      hasMorePages: true,
    );
  }

  PaginatedAppointmentsState copyWith({
    List<dynamic>? appointments,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return PaginatedAppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

/// Notifier para agendamentos paginados
class PaginatedAppointmentsNotifier
    extends StateNotifier<PaginatedAppointmentsState> {
  final Ref _ref;
  Map<String, dynamic>? _currentFilters;

  PaginatedAppointmentsNotifier(this._ref)
    : super(PaginatedAppointmentsState.initial());

  /// Busca a primeira página de agendamentos
  Future<void> fetchFirstPage({Map<String, dynamic>? filters}) async {
    _currentFilters = filters;
    state = state.copyWith(isLoading: true, currentPage: 1);

    try {
      final useCase = _ref.read(getAppointmentsUseCaseProvider);
      final appointments = await useCase.execute(
        page: 1,
        pageSize: 20,
        filters: filters,
      );

      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
        hasMorePages: appointments.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Busca a próxima página de agendamentos
  Future<void> fetchNextPage() async {
    if (!state.hasMorePages || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final useCase = _ref.read(getAppointmentsUseCaseProvider);
      final newAppointments = await useCase.execute(
        page: nextPage,
        pageSize: 20,
        filters: _currentFilters,
      );

      if (newAppointments.isEmpty) {
        state = state.copyWith(isLoading: false, hasMorePages: false);
        return;
      }

      state = state.copyWith(
        appointments: [...state.appointments, ...newAppointments],
        isLoading: false,
        currentPage: nextPage,
        hasMorePages: newAppointments.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Atualiza os filtros e busca agendamentos
  Future<void> updateFilters(Map<String, dynamic> filters) async {
    await fetchFirstPage(filters: filters);
  }

  /// Limpa os filtros
  Future<void> clearFilters() async {
    await fetchFirstPage();
  }
}
