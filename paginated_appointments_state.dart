import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_appointments_state.freezed.dart';

@freezed
class PaginatedAppointmentsState with _$PaginatedAppointmentsState {
  const factory PaginatedAppointmentsState({
    @Default([]) List<Appointment> appointments,
    @Default(true) bool hasMore,
    @Default(1) int page,
    // This state tracks the fetch status for the *entire list* (initial load/error)
    @Default(AsyncData<void>(null)) AsyncValue<void> fetchState,
  }) = _PaginatedAppointmentsState;
}
