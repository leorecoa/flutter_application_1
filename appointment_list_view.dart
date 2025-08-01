import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentListView extends ConsumerWidget {
  final AsyncValue<List<Appointment>> appointments;

  const AppointmentListView({super.key, required this.appointments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return appointments.when(
      data: (appointmentList) {
        if (appointmentList.isEmpty) {
          return const Center(child: Text('Nenhum agendamento para este dia.'));
        }
        return ListView.builder(
          itemCount: appointmentList.length,
          itemBuilder: (context, index) {
            final appointment = appointmentList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(appointment.clientName[0])),
                title: Text(appointment.clientName),
                subtitle: Text(
                  '${appointment.serviceName} - ${DateFormat.Hm().format(appointment.date)}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implementar navegação para detalhes do agendamento
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Erro ao carregar agendamentos: $error')),
    );
  }
}
