import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service.dart';
import '../widgets/add_appointment_dialog.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentsService = AppointmentsService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    
    try {
      final appointments = await _appointmentsService.getAppointments();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: _appointments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
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
                        return _buildAppointmentCard(appointment);
                      },
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
        trailing: Column(
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

  void _showAppointmentDetails(Appointment appointment) {
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
            Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)}'),
            Text('Valor: R\$ ${appointment.price.toStringAsFixed(2)}'),
            Text('Status: ${_getStatusText(appointment.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}