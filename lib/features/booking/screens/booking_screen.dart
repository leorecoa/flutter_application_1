import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final String professionalId;
  
  const BookingScreen({super.key, required this.professionalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Horário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Agendamento Público'),
            Text('Profissional: $professionalId'),
            const Text('Em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}