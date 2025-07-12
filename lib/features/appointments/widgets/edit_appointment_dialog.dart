import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service.dart';

class EditAppointmentDialog extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment) onAppointmentUpdated;

  const EditAppointmentDialog({
    super.key,
    required this.appointment,
    required this.onAppointmentUpdated,
  });

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentsService = AppointmentsService();
  
  late TextEditingController _clientNameController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _serviceController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  AppointmentStatus _selectedStatus = AppointmentStatus.scheduled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.appointment.clientName);
    _clientPhoneController = TextEditingController(text: widget.appointment.clientPhone);
    _serviceController = TextEditingController(text: widget.appointment.service);
    _priceController = TextEditingController(text: widget.appointment.price.toString());
    _notesController = TextEditingController(text: widget.appointment.notes ?? '');
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
    _selectedStatus = widget.appointment.status;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _serviceController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Agendamento'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Cliente',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Nome obrigatório' : null,
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
                  validator: (value) => value?.isEmpty == true ? 'Serviço obrigatório' : null,
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
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                        leading: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Hora: ${_selectedTime.format(context)}'),
                        leading: const Icon(Icons.access_time),
                        onTap: _selectTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppointmentStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: AppointmentStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusText(status)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateAppointment,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
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

  Future<void> _updateAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedAppointment = widget.appointment.copyWith(
      clientName: _clientNameController.text,
      clientPhone: _clientPhoneController.text,
      service: _serviceController.text,
      price: double.parse(_priceController.text),
      dateTime: updatedDateTime,
      status: _selectedStatus,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      final response = await _appointmentsService.updateAppointment(
        widget.appointment.id,
        updatedAppointment.toJson(),
      );

      if (response['success'] == true && mounted) {
        widget.onAppointmentUpdated(updatedAppointment);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}