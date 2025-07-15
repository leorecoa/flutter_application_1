import 'package:flutter/material.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service.dart';

class AddAppointmentDialog extends StatefulWidget {
  final Function(Appointment) onAppointmentAdded;

  const AddAppointmentDialog({
    super.key,
    required this.onAppointmentAdded,
  });

  @override
  State<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _appointmentsService = AppointmentsService();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Agendamento'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText: 'Serviço',
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Serviço obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Preço obrigatório';
                  if (double.tryParse(value!) == null) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                subtitle: Text(
                    'Hora: ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}'),
                leading: const Icon(Icons.schedule),
                onTap: _selectDateTime,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAppointment,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appointmentData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'clientName': _clientNameController.text,
      'clientPhone': _clientPhoneController.text,
      'service': _serviceController.text,
      'dateTime': _selectedDate.toIso8601String(),
      'price': double.parse(_priceController.text),
      'status': 'scheduled',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final response =
          await _appointmentsService.createAppointment(appointmentData);

      if (response['success'] == true) {
        final appointment = Appointment.fromJson(appointmentData);
        widget.onAppointmentAdded(appointment);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _serviceController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
