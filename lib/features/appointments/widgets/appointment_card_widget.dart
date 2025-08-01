import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../utils/appointment_status_utils.dart';

/// Widget para exibir um cartão de agendamento
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Function(Appointment) onDeletePressed;
  
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppointmentStatusUtils.getStatusColor(appointment.status),
          child: Icon(
            AppointmentStatusUtils.getStatusIcon(appointment.status),
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
            _buildPriceAndStatus(),
            _buildActionMenu(context),
          ],
        ),
        onTap: () => context.push('/appointment-details', extra: appointment),
      ),
    );
  }

  Widget _buildPriceAndStatus() {
    return Column(
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
          AppointmentStatusUtils.getStatusText(appointment.status),
          style: TextStyle(
            color: AppointmentStatusUtils.getStatusColor(appointment.status),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          context.push('/create-appointment', extra: appointment);
        } else if (value == 'delete') {
          _showDeleteDialog(context);
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
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              onDeletePressed(appointment);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}