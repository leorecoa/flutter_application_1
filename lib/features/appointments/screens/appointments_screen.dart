import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service.dart';
import '../services/appointments_service_v2.dart';
import '../widgets/add_appointment_dialog.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/edit_appointment_dialog.dart';
import '../widgets/recurring_appointment_dialog.dart';
import '../widgets/client_confirmation_widget.dart';
import '../../../core/services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentsService = AppointmentsService();
  final _appointmentsServiceV2 = AppointmentsServiceV2();
  final _notificationService = NotificationService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAppointments();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.init();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final appointments = await _appointmentsServiceV2.getAppointmentsList();
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendamentos'),
          actions: [
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab Calendário
                  RefreshIndicator(
                    onRefresh: _loadAppointments,
                    child: _appointments.isEmpty
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
                            appointments: _appointments,
                            onDaySelected: (selectedDay) {
                              // Ação quando dia é selecionado
                            },
                            onAppointmentTap: (appointment) =>
                                _showAppointmentDetails(appointment,
                                    showActions: true),
                          ),
                  ),
                  // Tab Lista
                  RefreshIndicator(
                    onRefresh: _loadAppointments,
                    child: _appointments.isEmpty
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
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
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
        onTap: () => _showAppointmentDetails(appointment),
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

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAppointmentDialog(
        onAppointmentAdded: (appointment) {
          setState(() {
            _appointments.add(appointment);
          });
        },
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment,
      {bool showActions = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.clientName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serviço: ${appointment.service}'),
            Text('Telefone: ${appointment.clientPhone}'),
            Text(
                'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}'),
            Text('Valor: R\$ ${appointment.price.toStringAsFixed(2)}'),
            Text('Status: ${_getStatusText(appointment.status)}'),
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Observações: ${appointment.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (showActions && appointment.status != AppointmentStatus.completed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditAppointmentDialog(appointment);
              },
              child: const Text('Editar'),
            ),
        ],
      ),
    );
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(
        appointment: appointment,
        onAppointmentUpdated: (updatedAppointment) {
          final index = _appointments.indexWhere((a) => a.id == appointment.id);
          if (index != -1) {
            setState(() {
              _appointments[index] = updatedAppointment;
            });
            // Reagendar notificações
            _notificationService.cancelAppointmentNotification(appointment.id);
            _notificationService
                .scheduleAppointmentReminder(updatedAppointment);
          }
        },
      ),
    );
  }

  void _showRecurringAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecurringAppointmentDialog(
        onAppointmentsCreated: (appointments) async {
          for (final appointment in appointments) {
            try {
              final response = await _appointmentsService
                  .createAppointment(appointment.toJson());
              if (response['success'] == true) {
                setState(() {
                  _appointments.add(appointment);
                });
                // Agendar notificações
                await _notificationService
                    .scheduleAppointmentReminder(appointment);
                await _notificationService
                    .scheduleClientConfirmationReminder(appointment);
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
      await _appointmentsServiceV2.deleteAppointment(appointment.id);
      setState(() {
        _appointments.removeWhere((a) => a.id == appointment.id);
      });
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
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;

    final appointment = _appointments[index];
    final newStatus =
        isConfirmed ? AppointmentStatus.confirmed : AppointmentStatus.cancelled;

    try {
      final updatedAppointment = appointment.copyWith(status: newStatus);
      final response = await _appointmentsService.updateAppointment(
        appointmentId,
        updatedAppointment.toJson(),
      );

      if (response['success'] == true) {
        setState(() {
          _appointments[index] = updatedAppointment;
        });

        final message =
            isConfirmed ? 'Agendamento confirmado!' : 'Agendamento cancelado!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isConfirmed ? Colors.green : Colors.orange,
          ),
        );

        // Notificação instantânea
        await _notificationService.showInstantNotification(
          title: 'Status Atualizado',
          body: message,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
