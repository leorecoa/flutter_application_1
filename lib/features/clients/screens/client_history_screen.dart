import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/client_model.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/api_service.dart';

class ClientHistoryScreen extends StatefulWidget {
  final String clientName;
  final String clientId;

  const ClientHistoryScreen({
    Key? key,
    required this.clientName,
    required this.clientId,
  }) : super(key: key);

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientAppointments();
  }

  Future<void> _loadClientAppointments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Implementação temporária
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _appointments = [
          Appointment(
            id: '1',
            professionalId: 'prof1',
            serviceId: 'service1',
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
            clientName: widget.clientName,
            clientPhone: '123456789', // Placeholder
            serviceName: 'Corte de Cabelo',
            price: 50.0,
            confirmedByClient: true,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico: ${widget.clientName}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum agendamento encontrado para ${widget.clientName}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadClientAppointments,
              child: ListView.builder(
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
          child: Icon(_getStatusIcon(appointment.status), color: Colors.white),
        ),
        title: Text(appointment.serviceName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(appointment.dateTime)),
            Text('R\$ ${appointment.price.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Chip(
          backgroundColor: _getStatusColor(appointment.status).withOpacity(0.2),
          label: Text(
            _getStatusText(appointment.status),
            style: TextStyle(
              color: _getStatusColor(appointment.status),
              fontWeight: FontWeight.bold,
            ),
          ),
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

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.serviceName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(appointment.dateTime),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Horário'),
              subtitle: Text(DateFormat('HH:mm').format(appointment.dateTime)),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Valor'),
              subtitle: Text('R\$ ${appointment.price.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: Icon(
                _getStatusIcon(appointment.status),
                color: _getStatusColor(appointment.status),
              ),
              title: const Text('Status'),
              subtitle: Text(_getStatusText(appointment.status)),
            ),
            if (appointment.notes?.isNotEmpty == true)
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Observações'),
                subtitle: Text(appointment.notes!),
              ),
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
