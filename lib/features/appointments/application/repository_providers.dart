import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/domain/repositories/appointment_repository.dart';
import 'package:flutter_application_1/data/repositories/appointment_repository_impl.dart';

/// Provider para o repositório de agendamentos
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl.provider(ref);
});