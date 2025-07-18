import 'package:flutter/foundation.dart';
import '../../../core/models/appointment_model.dart';

@immutable
class PaginatedAppointmentsState {
  final List<Appointment> appointments;
  final bool isLoadingFirstPage;
  final bool isLoadingNextPage;
  final String? lastKey;
  final Object? error;

  const PaginatedAppointmentsState({
    this.appointments = const [],
    this.isLoadingFirstPage = true,
    this.isLoadingNextPage = false,
    this.lastKey,
    this.error,
  });

  bool get hasMore => lastKey != null;

  PaginatedAppointmentsState copyWith({
    List<Appointment>? appointments,
    bool? isLoadingFirstPage,
    bool? isLoadingNextPage,
    String? lastKey,
    Object? error,
  }) {
    return PaginatedAppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      lastKey: lastKey,
      error: error,
    );
  }
}