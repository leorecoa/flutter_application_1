import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/models/notification_action_event.dart';
import '../../../core/services/notification_service.dart';
import '../../../features/notifications/application/notification_listener_mixin.dart';
import '../application/appointment_providers.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/recurring_appointment_dialog.dart';
import '../widgets/client_confirmation_widget.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> 
    with NotificationActionListener {
  DateTime? _selectedDay;

  @override
  void onNotificationActionProcessed(NotificationActionEvent event) {
    // Recarregar agendamentos quando uma ação de notificação for processada
    if (_selectedDay != null) {
      ref.invalidate(appointmentsProvider(_selectedDay));
    } else {
      ref.invalidate(appointmentsProvider(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar o provider para obter os agendamentos
    final appointmentsAsync = ref.watch(appointmentsProvider(_selectedDay));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendamentos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.push('/notification-history'),
              tooltip: 'Histórico de Notificações',
            ),
            IconButton(
              icon: const Icon(Icons.repeat),
              onPressed: () => _showRecurringAppointmentDialog(),
              tooltip: 'Agendamento Recorrente',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/create-appointment'),
              tooltip: 'Novo Agendamento',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendário'),
              Tab(icon: Icon(Icons.list), text: 'Lista'),
            ],
          ),
        ),
        body: appointmentsAsync.when(
          data: (appointments) => TabBarView(
            children: [
              // Tab Calendário
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(appointmentsProvider(_selectedDay));
                },
                child: appointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum agendamento encontrado'),
                          ],
                        ),
                      )
                    : CalendarWidget(
                        appointments: appointments,
                        onDaySelected: (selectedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                          });
                        },
                        onAppointmentTap: (appointment) =>
                            context.push('/appointment-details', extra: appointment),
                      ),
              ),
              // Tab Lista
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(appointmentsProvider(_selectedDay));
                },
                child: appointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum agendamento encontrado'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return Column(
                            children: [
                              _buildAppointmentCard(appointment),
                              if (appointment.status ==
                                      AppointmentStatus.scheduled ||
                                  appointment.status ==
                                      AppointmentStatus.confirmed)
                                ClientConfirmationWidget(
                                  appointment: appointment,
                                  onConfirmationChanged:
                                      _handleConfirmationChange,
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Erro ao carregar agendamentos: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: Icon(
            _getStatusIcon(appointment.status),
            color: Colors.white,
          ),
        ),
        title: Text(appointment.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.service),
            Text(
              dateFormat.format(appointment.dateTime),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'R\$ ${appointment.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getStatusText(appointment.status),
                  style: TextStyle(
                    color: _getStatusColor(appointment.status),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/create-appointment', extra: appointment);
                } else if (value == 'delete') {
                  _showDeleteDialog(appointment);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => context.push('/appointment-details', extra: appointment),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
    }
  }

  void _showRecurringAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecurringAppointmentDialog(
        onAppointmentsCreated: (appointments) async {
          for (final appointment in appointments) {
            try {
              final appointmentsService = ref.read(appointmentsServiceProvider);
              final response = await appointmentsService.createAppointment(appointment.toJson());
              
              if (response['success'] == true) {
                // Agendar notificações
                final notificationService = ref.read(notificationServiceProvider);
                await notificationService.scheduleAppointmentReminders(appointment);
                
                // Recarregar agendamentos
                ref.invalidate(appointmentsProvider(_selectedDay));
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao criar agendamento: $e')),
              );
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${appointments.length} agendamentos criados com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o agendamento de ${appointment.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAppointment(appointment);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    try {
      final appointmentsService = ref.read(appointmentsServiceProvider);
      await appointmentsService.deleteAppointment(appointment.id);
      
      // Cancelar notificações
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelAppointmentNotifications(appointment.id);
      
      // Recarregar agendamentos
      ref.invalidate(appointmentsProvider(_selectedDay));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamento excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir agendamento: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleConfirmationChange(
      String appointmentId, bool isConfirmed) async {
    try {
      final appointmentsService = ref.read(appointmentsServiceProvider);
      final appointments = await appointmentsService.getAppointmentsList();
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);
      
      final newStatus =
          isConfirmed ? AppointmentStatus.confirmed : AppointmentStatus.cancelled;
      
      final updatedAppointment = appointment.copyWith(status: newStatus);
      final response = await appointmentsService.updateAppointment(
        appointmentId,
        updatedAppointment.toJson(),
      );

      if (response['success'] == true) {
        // Recarregar agendamentos
        ref.invalidate(appointmentsProvider(_selectedDay));

        final message =
            isConfirmed ? 'Agendamento confirmado!' : 'Agendamento cancelado!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isConfirmed ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}