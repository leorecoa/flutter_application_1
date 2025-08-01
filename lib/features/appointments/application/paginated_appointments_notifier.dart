import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_appointments_usecase.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../core/tenant/tenant_context.dart';

/// Provider para o caso de uso de buscar agendamentos
final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  final tenantContext = ref.watch(tenantContextProvider);
  return GetAppointmentsUseCase(repository, tenantContext);
});

/// Provider para o repositório de agendamentos
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  throw UnimplementedError('Implemente este provider na camada de dados');
});

/// Provider para o contexto do tenant
final tenantContextProvider = Provider<TenantContext>((ref) {
  throw UnimplementedError('Implemente este provider na camada de tenant');
});

/// Notifier para gerenciar o estado paginado de agendamentos
class PaginatedAppointmentsNotifier
    extends StateNotifier<PaginatedAppointmentsState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;

  PaginatedAppointmentsNotifier(this._getAppointmentsUseCase)
    : super(PaginatedAppointmentsState.initial());

  /// Busca a primeira página de agendamentos
  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true);
    try {
      final appointments = await _getAppointmentsUseCase.execute(
        pageSize: state.pageSize,
        filters: state.filters,
      );
      state = state.copyWith(
        appointments: appointments,
        currentPage: 1,
        isLoading: false,
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Busca a próxima página de agendamentos
  Future<void> fetchNextPage() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final appointments = await _getAppointmentsUseCase.execute(
        page: nextPage,
        pageSize: state.pageSize,
        filters: state.filters,
      );

      if (appointments.isEmpty) {
        state = state.copyWith(isLoading: false, hasMorePages: false);
      } else {
        state = state.copyWith(
          appointments: [...state.appointments, ...appointments],
          currentPage: nextPage,
          isLoading: false,
          hasError: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Atualiza os filtros e recarrega os agendamentos
  Future<void> updateFilters(Map<String, dynamic> filters) async {
    state = state.copyWith(filters: filters);
    await fetchFirstPage();
  }
}

/// Estado para a lista paginada de agendamentos
class PaginatedAppointmentsState {
  final List<dynamic> appointments;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasMorePages;
  final Map<String, dynamic> filters;

  const PaginatedAppointmentsState({
    required this.appointments,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.hasMorePages,
    required this.filters,
  });

  /// Estado inicial
  factory PaginatedAppointmentsState.initial() {
    return const PaginatedAppointmentsState(
      appointments: [],
      currentPage: 0,
      pageSize: 20,
      isLoading: false,
      hasError: false,
      hasMorePages: true,
      filters: {},
    );
  }

  /// Cria uma cópia modificada do estado
  PaginatedAppointmentsState copyWith({
    List<dynamic>? appointments,
    int? currentPage,
    int? pageSize,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? hasMorePages,
    Map<String, dynamic>? filters,
  }) {
    return PaginatedAppointmentsState(
      appointments: appointments ?? this.appointments,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      filters: filters ?? this.filters,
    );
  }
}
