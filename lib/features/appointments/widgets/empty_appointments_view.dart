import 'package:flutter/material.dart';

/// Widget para exibir uma mensagem quando não há agendamentos
class EmptyAppointmentsView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyAppointmentsView({
    super.key,
    this.message = 'Nenhum agendamento encontrado',
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
