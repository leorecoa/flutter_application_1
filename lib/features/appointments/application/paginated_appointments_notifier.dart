import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appointments_service_v2.dart';
import 'paginated_appointments_state.dart';

class PaginatedAppointmentsNotifier extends StateNotifier<PaginatedAppointmentsState> {
  final AppointmentsServiceV2 _service;
  final Map<String, dynamic> _filters;

  PaginatedAppointmentsNotifier(this._service, this._filters)
      : super(const PaginatedAppointmentsState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = const PaginatedAppointmentsState(isLoadingFirstPage: true);
    try {
      final response = await _service.getAppointmentsList(filters: _filters);
      state = state.copyWith(
        appointments: response.items,
        lastKey: response.lastKey,
        isLoadingFirstPage: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoadingFirstPage: false);
      print('Erro ao buscar primeira página: $e');
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingNextPage || !state.hasMore) return;

    state = state.copyWith(isLoadingNextPage: true);
    try {
      final response = await _service.getAppointmentsList(
        filters: _filters,
        lastKey: state.lastKey,
      );
      state = state.copyWith(
        appointments: [...state.appointments, ...response.items],
        lastKey: response.lastKey,
        isLoadingNextPage: false,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoadingNextPage: false);
    }
  }
}