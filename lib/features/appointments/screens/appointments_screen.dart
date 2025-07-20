import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/models/notification_action_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/debouncer.dart';
import '../application/appointment_screen_controller.dart';
import '../application/recurring_appointment_controller.dart';
import '../../../features/notifications/application/notification_listener_mixin.dart';
import '../application/appointment_providers.dart';
import '../widgets/appointment_card_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/client_confirmation_widget.dart';
import '../widgets/empty_appointments_view.dart';
import '../widgets/filter_bar_widget.dart';
import '../widgets/recurring_appointment_dialog.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/appointment_statistics_widget.dart';
import '../widgets/batch_operations_widget.dart';
import '../utils/appointment_status_utils.dart';
import '../utils/appointment_export_utils.dart';
import '../application/batch_operations_controller.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> 
    with NotificationActionListenerMixin {  
  // Lista de agendamentos selecionados para operações em lote
  final List<Appointment> _selectedAppointments = [];
  bool _selectionMode = false;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAppointmentsProvider.notifier).fetchNextPage();
    }
  }

  @override
  void onNotificationActionProcessed(NotificationAction action) {
    // Recarregar agendamentos quando uma ação de notificação for processada
    // Apenas a ação abaixo é necessária, ela já aciona a recarga com os filtros atuais
    ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: _buildScaffold(context),
    );
  }
  
  Widget _buildScaffold(BuildContext context) {
    // Ouve o controller para exibir SnackBars de sucesso/erro de forma centralizada
    ref.listen<AsyncValue<void>>(appointmentScreenControllerProvider, (_, state) {
      state.when(
        error: (error, stackTrace) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $error'), backgroundColor: Colors.red),
          );
        },
        loading: () {},
        data: (_) {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: _buildAppBarActions(),
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendário'),
            Tab(icon: Icon(Icons.list), text: 'Lista'),
          ],
        ),
      ),
      body: Column(
        children: [
          AppointmentSearchBar(),
          AppointmentFilterBar(searchController: _searchController),
          // Widget de operações em lote (exibido apenas quando há seleção)
          if (_selectionMode)
            BatchOperationsWidget(
              selectedAppointments: _selectedAppointments,
              onOperationComplete: _exitSelectionMode,
              onCancel: _exitSelectionMode,
            ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCalendarTab(),
                _buildPaginatedList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildAppBarActions() {
    // Ações diferentes dependendo do modo de seleção
    if (_selectionMode) {
      return [
        TextButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Cancelar Seleção'),
          onPressed: _exitSelectionMode,
        ),
      ];
    }
    
    return [
      IconButton(
        icon: const Icon(Icons.select_all),
        onPressed: _enterSelectionMode,
        tooltip: 'Selecionar Vários',
      ),
      IconButton(
        icon: const Icon(Icons.file_download),
        onPressed: _exportAppointments,
        tooltip: 'Exportar Agendamentos',
      ),
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
    ];
  }
  
  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedAppointments.clear();
    });
  }
  
  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedAppointments.clear();
    });
  }
  
  Future<void> _exportAppointments() async {
    try {
      final appointmentsAsync = await ref.read(allAppointmentsProvider.future);
      await AppointmentExportUtils.exportToCsv(appointmentsAsync);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agendamentos exportados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar agendamentos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Widget de estatísticas
        const AppointmentStatisticsWidget(),
        
        // Calendário
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final appointmentsAsync = ref.watch(allAppointmentsProvider);
              return appointmentsAsync.when(
                data: (appointments) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allAppointmentsProvider);
                  },
                  child: appointments.isEmpty
                      ? const EmptyAppointmentsView()
                      : CalendarWidget(
                          appointments: appointments,
                          onDaySelected: (selectedDay) {},
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
        ),
      ],
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
          return const EmptyAppointmentsView(
            message: 'Nenhum agendamento encontrado para os filtros selecionados',
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
                  _selectionMode
                      ? _buildSelectableAppointmentCard(appointment)
                      : AppointmentCard(
                          appointment: appointment,
                          onDeletePressed: _deleteAppointment,
                        ),
                  if (!_selectionMode &&
                      (appointment.status == AppointmentStatus.scheduled ||
                       appointment.status == AppointmentStatus.confirmed))
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





  void _showRecurringAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecurringAppointmentDialog(
        onAppointmentsCreated: (newAppointments) async {
          // Delega a lógica para o controller
          final controller = ref.read(recurringAppointmentControllerProvider.notifier);
          final result = await controller.createRecurringAppointments(newAppointments);
          
          // Garante que o widget ainda está na árvore antes de usar o context
          if (!mounted) return;
          
          // Exibe um único feedback consolidado para o usuário
          final message = StringBuffer('${result.successCount} agendamentos criados com sucesso.');
          if (result.errors.isNotEmpty) {
            message.write('\nFalhas: ${result.errors.length}.');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.toString()),
              backgroundColor: result.errors.isEmpty ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 5),
              action: result.errors.isNotEmpty ? SnackBarAction(
                label: 'DETALHES', 
                onPressed: () => _showErrorDetailsDialog(result.errors),
              ) : null,
            ),
          );
        },
      ),
    );
  }
  
  void _showErrorDetailsDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes dos erros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('• $e'),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }



  Future<void> _deleteAppointment(Appointment appointment) async {
    // Delega a lógica para o controller, que gerencia o estado e as mensagens de erro
    await ref.read(appointmentScreenControllerProvider.notifier)
        .deleteAppointment(appointment);
    
    // Feedback visual já é gerenciado pelo listener do controller no _buildScaffold
  }

  Future<void> _handleConfirmationChange(
      String appointmentId, bool isConfirmed) async {
    // Delega a lógica para o controller, que gerencia o estado e as mensagens de erro
    await ref.read(appointmentScreenControllerProvider.notifier)
        .updateAppointmentStatus(appointmentId, isConfirmed);
    
    // Feedback visual já é gerenciado pelo listener do controller no _buildScaffold
  }
  
  Widget _buildSelectableAppointmentCard(Appointment appointment) {
    final isSelected = _selectedAppointments.any((a) => a.id == appointment.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => _toggleAppointmentSelection(appointment),
        title: Text(appointment.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.service),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppointmentStatusUtils.getStatusText(appointment.status),
              style: TextStyle(
                color: AppointmentStatusUtils.getStatusColor(appointment.status),
                fontSize: 12,
              ),
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: AppointmentStatusUtils.getStatusColor(appointment.status),
          child: Icon(
            AppointmentStatusUtils.getStatusIcon(appointment.status),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  void _toggleAppointmentSelection(Appointment appointment) {
    setState(() {
      final isSelected = _selectedAppointments.any((a) => a.id == appointment.id);
      
      if (isSelected) {
        _selectedAppointments.removeWhere((a) => a.id == appointment.id);
      } else {
        _selectedAppointments.add(appointment);
      }
      
      // Se não houver mais seleções, sair do modo de seleção
      if (_selectedAppointments.isEmpty) {
        _selectionMode = false;
      }
    });
  }
  
  // Método auxiliar para obter o texto do status
  // Usado apenas para compatibilidade com o código existente
  // Idealmente, deveria usar AppointmentStatusUtils.getStatusText
  String _getStatusText(AppointmentStatus status) {
    return AppointmentStatusUtils.getStatusText(status);
  }
}