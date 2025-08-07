import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

// Modelo básico de agendamento
class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final DateTime dateTime;
  final DateTime startTime;
  final DateTime endTime;

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.dateTime,
    required this.startTime,
    required this.endTime,
  });
}

// Provider mock para agendamentos
final appointmentsProvider =
    FutureProvider.family<List<Appointment>, DateTime>((ref, date) async {
  // Simula dados de agendamentos para demonstração
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    Appointment(
      id: '1',
      clientName: 'João Silva',
      serviceName: 'Corte de Cabelo',
      dateTime: date,
      startTime: DateTime(date.year, date.month, date.day, 9),
      endTime: DateTime(date.year, date.month, date.day, 10),
    ),
    Appointment(
      id: '2',
      clientName: 'Maria Santos',
      serviceName: 'Manicure',
      dateTime: date,
      startTime: DateTime(date.year, date.month, date.day, 14),
      endTime: DateTime(date.year, date.month, date.day, 15),
    ),
  ];
});

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Inicializa o dia selecionado com o dia focado
    _selectedDay ??= _focusedDay;

    final appointmentsForSelectedDay = ref.watch(
      appointmentsProvider(_selectedDay!),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              // Carrega os eventos para o dia visível no calendário
              final appointments = ref.watch(appointmentsProvider(day)).value;
              return appointments ?? [];
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: appointmentsForSelectedDay.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const Center(
                      child: Text('Nenhum agendamento para este dia.'));
                }
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return ListTile(
                      title: Text(appointment.clientName),
                      subtitle: Text(
                          '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}'),
                      trailing: Text(appointment.serviceName),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erro ao carregar agendamentos: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar a navegação para a tela de criação de agendamento
          // context.go('/create-appointment'); // Substitua pela sua rota
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Criar agendamento (em breve!)')));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
