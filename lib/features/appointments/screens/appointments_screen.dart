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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAppointmentsProvider.notifier).fetchNextPage();
    }
  }

  @override
  void onNotificationActionProcessed(NotificationActionEvent event) {
    // Recarregar agendamentos quando uma ação de notificação for processada
    ref.invalidate(allAppointmentsProvider);
    ref.invalidate(filteredAppointmentsProvider);
    ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
    if (_selectedDay != null) {
      ref.invalidate(appointmentsProvider(_selectedDay));
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
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab Calendário
                  Consumer(
                    builder: (context, ref, child) {
                      final appointmentsAsync = ref.watch(allAppointmentsProvider);
                      return appointmentsAsync.when(
                        data: (appointments) => RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(allAppointmentsProvider);
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
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => Center(
                          child: Text('Erro ao carregar agendamentos: $error'),
                        ),
                      );
                    },
                  ),
                  // Tab Lista com Paginação
                  _buildPaginatedList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginatedList() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(paginatedAppointmentsProvider);

        if (state.isLoadingFirstPage) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.appointments.isEmpty) {
          return Center(child: Text('Erro: ${state.error}'));
        }

        if (state.appointments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum agendamento encontrado para os filtros selecionados'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.appointments.length + (state.isLoadingNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.appointments.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final appointment = state.appointments[index];
              return Column(
                children: [
                  _buildAppointmentCard(appointment),
                  if (appointment.status == AppointmentStatus.scheduled ||
                      appointment.status == AppointmentStatus.confirmed)
                    ClientConfirmationWidget(
                      appointment: appointment,
                      onConfirmationChanged: _handleConfirmationChange,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    final currentFilters = ref.watch(appointmentFiltersProvider);
    final currentStatus = currentFilters['status'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtro de Status
            PopupMenuButton<String?>(
              onSelected: (status) {
                final newFilters = Map<String, dynamic>.from(currentFilters);
                if (status == null) {
                  newFilters.remove('status');
                } else {
                  newFilters['status'] = status;
                }
                ref.read(appointmentFiltersProvider.notifier).state = newFilters;
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: null, child: Text("Todos os Status")),
                ...AppointmentStatus.values.map((s) => PopupMenuItem(
                      value: s.name,
                      child: Text(_getStatusText(s)),
                    )),
              ],
              child: Chip(
                avatar: const Icon(Icons.filter_list, size: 16),
                label: Text(currentStatus != null 
                    ? _getStatusText(AppointmentStatus.values.byName(currentStatus)) 
                    : 'Status'),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 8),
            
            // Filtro de Data
            if (currentFilters.containsKey('date'))
              InputChip(
                label: Text('Data: ${DateFormat('dd/MM/yyyy').format(currentFilters['date'])}'),
                onDeleted: () {
                  final newFilters = Map<String, dynamic>.from(currentFilters);
                  newFilters.remove('date');
                  ref.read(appointmentFiltersProvider.notifier).state = newFilters;
                },
              )
            else
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Selecionar Data'),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (selectedDate != null) {
                    final newFilters = Map<String, dynamic>.from(currentFilters);
                    newFilters['date'] = selectedDate;
                    ref.read(appointmentFiltersProvider.notifier).state = newFilters;
                  }
                },
              ),
            const SizedBox(width: 8),
            
            // Botão para limpar filtros
            if (currentFilters.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
                onPressed: () {
                  ref.read(appointmentFiltersProvider.notifier).state = {};
                },
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
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao criar agendamento: $e')),
              );
            }
          }
          
          // Recarregar agendamentos
          ref.invalidate(allAppointmentsProvider);
          ref.invalidate(filteredAppointmentsProvider);
          ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
          
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
      ref.invalidate(allAppointmentsProvider);
      ref.invalidate(filteredAppointmentsProvider);
      ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
      
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
      final response = await appointmentsService.getAppointmentsList();
      final appointment = response.items.firstWhere((a) => a.id == appointmentId);
      
      final newStatus =
          isConfirmed ? AppointmentStatus.confirmed : AppointmentStatus.cancelled;
      
      final updatedAppointment = appointment.copyWith(status: newStatus);
      final updateResponse = await appointmentsService.updateAppointment(
        appointmentId,
        updatedAppointment.toJson(),
      );

      if (updateResponse['success'] == true) {
        // Recarregar agendamentos
        ref.invalidate(allAppointmentsProvider);
        ref.invalidate(filteredAppointmentsProvider);
        ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();

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