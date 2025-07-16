import 'package:agendafacil/src/features/appointments/application/appointment_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendafacil/src/features/appointments/data/appointment_model.dart';

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
            firstDay: DateTime.utc(2020, 1, 1),
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
                          '${appointment.startTime.hour}:${appointment.startTime.minute} - ${appointment.endTime.hour}:${appointment.endTime.minute}'),
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
