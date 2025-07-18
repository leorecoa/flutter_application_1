import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/notification_service.dart';
import '../services/appointments_service_v2.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  
  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final _appointmentsService = AppointmentsServiceV2();
  bool _isLoading = false;
  late Appointment _appointment;
  
  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editAppointment(),
            tooltip: 'Editar',
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _appointment.service,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              backgroundColor: _getStatusColor(_appointment.status).withOpacity(0.1),
                              label: Text(
                                _getStatusText(_appointment.status),
                                style: TextStyle(
                                  color: _getStatusColor(_appointment.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_appointment.dateTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('HH:mm').format(_appointment.dateTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timelapse, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Duração: ${_appointment.duration ?? 60} minutos',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'R\$ ${_appointment.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Informações do cliente
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cliente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(_appointment.clientName),
                          subtitle: Text(_appointment.clientPhone),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notificações
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notificações',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: const Text('Lembrete 1 dia antes'),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              _appointment.dateTime.subtract(const Duration(days: 1))
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: const Text('Lembrete 1 hora antes'),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              _appointment.dateTime.subtract(const Duration(hours: 1))
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _toggleNotifications,
                            icon: const Icon(Icons.notifications_off),
                            label: const Text('Cancelar Notificações'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Observações
                if (_appointment.notes?.isNotEmpty == true)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Observações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(_appointment.notes!),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_appointment.status == AppointmentStatus.scheduled || 
                        _appointment.status == AppointmentStatus.confirmed)
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(AppointmentStatus.cancelled),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (_appointment.status == AppointmentStatus.scheduled)
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(AppointmentStatus.confirmed),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (_appointment.status == AppointmentStatus.confirmed)
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(AppointmentStatus.completed),
                        icon: const Icon(Icons.done_all),
                        label: const Text('Concluir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
  
  Future<void> _editAppointment() async {
    context.push('/create-appointment', extra: _appointment);
  }
  
  Future<void> _updateStatus(AppointmentStatus newStatus) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _appointmentsService.updateAppointmentStatus(
        _appointment.id,
        _getStatusApiValue(newStatus),
      );
      
      if (response['success'] == true) {
        setState(() {
          _appointment = _appointment.copyWith(status: newStatus);
          _isLoading = false;
        });
        
        if (newStatus == AppointmentStatus.cancelled) {
          // Cancelar notificações se o agendamento for cancelado
          await NotificationService.instance.cancelAppointmentNotifications(_appointment.id);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status atualizado para ${_getStatusText(newStatus)}'),
              backgroundColor: _getStatusColor(newStatus),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _toggleNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      await NotificationService.instance.cancelAppointmentNotifications(_appointment.id);
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificações canceladas'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar notificações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
  
  String _getStatusApiValue(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'pendente';
      case AppointmentStatus.confirmed:
        return 'confirmado';
      case AppointmentStatus.completed:
        return 'concluido';
      case AppointmentStatus.cancelled:
        return 'cancelado';
    }
  }
}