import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para o caso de uso de exportação de agendamentos
final exportAppointmentsUseCaseProvider = Provider<ExportAppointmentsUseCase>((
  ref,
) {
  return ExportAppointmentsUseCaseImpl();
});

/// Interface para o caso de uso de exportação de agendamentos
abstract class ExportAppointmentsUseCase {
  Future<String> execute({String format = 'csv'});
}

/// Implementação simplificada do caso de uso de exportação de agendamentos
class ExportAppointmentsUseCaseImpl implements ExportAppointmentsUseCase {
  @override
  Future<String> execute({String format = 'csv'}) async {
    // Simulação para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 500));
    return 'id,cliente,data,hora,serviço\n1,João,2023-07-20,14:00,Corte\n2,Maria,2023-07-21,15:30,Manicure';
  }
}
