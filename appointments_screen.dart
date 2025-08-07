import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado do provider de agendamentos.
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Agendamentos')),
      // O `when` do AsyncValue trata os estados de loading, error e data.
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento encontrado ou nenhuma empresa selecionada.',
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              // TODO: Substituir por um widget AppointmentCard
              return ListTile(
                title: Text(appointment.clientName),
                subtitle: Text(appointment.serviceName),
              );
            },
          );
        },
      ),
    );
  }
}
