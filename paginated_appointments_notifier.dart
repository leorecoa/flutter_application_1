import 'package:flutter_application_1/features/appointments/presentation/controllers/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/presentation/pagination/paginated_appointments_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedAppointmentsNotifier
    extends StateNotifier<PaginatedAppointmentsState> {
  PaginatedAppointmentsNotifier(this._ref, this._filters)
    : super(const PaginatedAppointmentsState());

  final Ref _ref;
  final Map<String, dynamic> _filters;
  static const _pageSize = 20;

  Future<void> fetchFirstPage() async {
    state = state.copyWith(fetchState: const AsyncLoading());
    try {
      final appointments = await _ref
          .read(appointmentScreenControllerProvider.notifier)
          .fetchAppointments(filters: _filters);

      state = PaginatedAppointmentsState(
        appointments: appointments,
        hasMore: appointments.length == _pageSize,
        page: 1,
        fetchState: const AsyncData(null),
      );
    } catch (e, s) {
      state = state.copyWith(fetchState: AsyncError(e, s));
    }
  }

  Future<void> fetchNextPage() async {
    // Prevents multiple simultaneous fetches and fetching beyond the end.
    if (state.fetchState is AsyncLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(fetchState: const AsyncLoading());

    final nextPage = state.page + 1;
    try {
      final newAppointments = await _ref
          .read(appointmentScreenControllerProvider.notifier)
          .fetchAppointments(page: nextPage, filters: _filters);

      state = state.copyWith(
        appointments: [...state.appointments, ...newAppointments],
        hasMore: newAppointments.length == _pageSize,
        page: nextPage,
        fetchState: const AsyncData(null),
      );
    } catch (e, s) {
      state = state.copyWith(fetchState: AsyncError(e, s));
    }
  }
}
