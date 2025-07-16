import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/appointments_service_v2.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;
  const CreateAppointmentScreen({super.key, this.appointment});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _appointmentsServiceV2 = AppointmentsServiceV2();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  bool get isEditing => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _clientNameController.text = widget.appointment!.clientName;
      _clientPhoneController.text = widget.appointment!.clientPhone;
      _serviceController.text = widget.appointment!.service;
      _priceController.text = widget.appointment!.price.toString();
      _notesController.text = widget.appointment!.notes ?? '';
      _selectedDate = widget.appointment!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Agendamento' : 'Novo Agendamento'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAppointment,
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Cliente',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientPhoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Serviço',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço (R\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Horário'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: _selectTime,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
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

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (isEditing) {
        // Atualizar agendamento existente
        final appointmentData = {
          'clientName': _clientNameController.text,
          'clientPhone': _clientPhoneController.text,
          'service': _serviceController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'appointmentDateTime': appointmentDateTime.toIso8601String(),
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
        };
        
        await _appointmentsServiceV2.updateAppointment(
          widget.appointment!.id,
          appointmentData,
        );
      } else {
        // Criar novo agendamento
        await _appointmentsServiceV2.createAppointmentModel(
        professionalId: 'PROF#default',
        serviceId: 'SERV#${_serviceController.text.toLowerCase()}',
        appointmentDateTime: appointmentDateTime,
        clientName: _clientNameController.text,
        clientPhone: _clientPhoneController.text,
        service: _serviceController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Agendamento atualizado com sucesso!' : 'Agendamento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar agendamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
}