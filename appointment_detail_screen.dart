import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Criar um provider para buscar os detalhes completos do agendamento usando o ID.
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Agendamento')),
      body: Center(
        child: Text('Detalhes para o agendamento ID: $appointmentId'),
      ),
    );
  }
}
