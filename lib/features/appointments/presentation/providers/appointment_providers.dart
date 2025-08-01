import 'package:flutter_application_1/features/appointments/presentation/pagination/paginated_appointments_notifier.dart';
import 'package:flutter_application_1/features/appointments/presentation/pagination/paginated_appointments_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to hold the current filter state for the appointments list.
/// For example: {'clientName': 'John', 'status': 'confirmed'}
final appointmentFilterProvider =
    StateProvider.autoDispose<Map<String, dynamic>>((ref) => {});

final paginatedAppointmentsProvider =
    StateNotifierProvider.autoDispose<
      PaginatedAppointmentsNotifier,
      PaginatedAppointmentsState
    >((ref) {
      // Watch the filters. When they change, this provider will be re-created,
      // automatically triggering a refetch of the data with the new filters.
      final filters = ref.watch(appointmentFilterProvider);
      return PaginatedAppointmentsNotifier(ref, filters)..fetchFirstPage();
    });
