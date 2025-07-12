import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/appointment_model.dart';

class ClientConfirmationWidget extends StatelessWidget {
  final Appointment appointment;
  final Function(String, bool) onConfirmationChanged;

  const ClientConfirmationWidget({
    super.key,
    required this.appointment,
    required this.onConfirmationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(appointment.status),
                  color: _getStatusColor(appointment.status),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${_getStatusText(appointment.status)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(appointment.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (appointment.status == AppointmentStatus.scheduled) ...[
              const Text(
                'Aguardando confirmação do cliente',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _generateConfirmationLink(context),
                      icon: const Icon(Icons.link),
                      label: const Text('Gerar Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendWhatsAppMessage(context),
                      icon: const Icon(Icons.message),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onConfirmationChanged(appointment.id, true),
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text('Confirmar Manualmente'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onConfirmationChanged(appointment.id, false),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
            
            if (appointment.status == AppointmentStatus.confirmed) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Cliente confirmou o agendamento',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _sendReminderMessage(context),
                icon: const Icon(Icons.notifications),
                label: const Text('Enviar Lembrete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            
            if (appointment.status == AppointmentStatus.cancelled) ...[
              const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Agendamento cancelado',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => onConfirmationChanged(appointment.id, true),
                icon: const Icon(Icons.restore),
                label: const Text('Reagendar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _generateConfirmationLink(BuildContext context) {
    final confirmationUrl = 'https://main.d31iho7gw23enq.amplifyapp.com/confirm/${appointment.id}';
    
    Clipboard.setData(ClipboardData(text: confirmationUrl));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link de confirmação copiado!'),
        backgroundColor: Colors.green,
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link de Confirmação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envie este link para o cliente confirmar:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                confirmationUrl,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: confirmationUrl));
              Navigator.pop(context);
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  void _sendWhatsAppMessage(BuildContext context) {
    final phone = appointment.clientPhone.replaceAll(RegExp(r'[^\d]'), '');
    final message = '''
Olá ${appointment.clientName}! 👋

Seu agendamento foi confirmado:
📅 Serviço: ${appointment.service}
🕐 Data/Hora: ${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} às ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}
💰 Valor: R\$ ${appointment.price.toStringAsFixed(2)}

Para confirmar, clique no link:
https://main.d31iho7gw23enq.amplifyapp.com/confirm/${appointment.id}

Obrigado! 🙏
''';

    final whatsappUrl = 'https://wa.me/55$phone?text=${Uri.encodeComponent(message)}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensagem WhatsApp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mensagem que será enviada:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 16),
            const Text('Copie o link abaixo e abra no navegador:'),
            const SizedBox(height: 8),
            SelectableText(
              whatsappUrl,
              style: const TextStyle(fontSize: 10, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: whatsappUrl));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link do WhatsApp copiado!')),
              );
            },
            child: const Text('Copiar Link'),
          ),
        ],
      ),
    );
  }

  void _sendReminderMessage(BuildContext context) {
    final reminderMessage = '''
Lembrete: Você tem um agendamento amanhã! 📅

Serviço: ${appointment.service}
Data/Hora: ${appointment.dateTime.day}/${appointment.dateTime.month} às ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}

Nos vemos lá! 😊
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lembrete Enviado'),
        content: Text(reminderMessage),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
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
        return 'Aguardando Confirmação';
      case AppointmentStatus.confirmed:
        return 'Confirmado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
    }
  }
}