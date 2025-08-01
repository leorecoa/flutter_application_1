import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/src/features/appointments/application/appointment_detail_provider.dart';
import 'package:flutter_application_1/src/features/appointments/application/appointments_screen_controller.dart';

class AppointmentEditScreen extends ConsumerStatefulWidget {
  final Appointment appointment;

  const AppointmentEditScreen({super.key, required this.appointment});

  @override
  ConsumerState<AppointmentEditScreen> createState() =>
      _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends ConsumerState<AppointmentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late final TextEditingController _serviceNameController;
  late final TextEditingController _priceController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appointment = widget.appointment;
    _clientNameController = TextEditingController(text: appointment.clientName);
    _serviceNameController = TextEditingController(
      text: appointment.serviceName,
    );
    _priceController = TextEditingController(
      text: appointment.price.toStringAsFixed(2),
    );
    _selectedDate = appointment.date;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _serviceNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedAppointment = widget.appointment.copyWith(
        clientName: _clientNameController.text,
        serviceName: _serviceNameController.text,
        price:
            double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
        date: _selectedDate,
      );

      try {
        await ref
            .read(appointmentsScreenControllerProvider.notifier)
            .updateAppointment(updatedAppointment);

        // Invalida os providers para forçar a atualização dos dados
        ref.invalidate(appointmentDetailProvider(widget.appointment.id));
        ref.invalidate(appointmentsScreenControllerProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Volta para a tela de detalhes
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao atualizar agendamento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Agendamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Cliente',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceNameController,
                      decoration: const InputDecoration(labelText: 'Serviço'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          (double.tryParse(value!.replaceAll(',', '.')) == null)
                          ? 'Valor inválido'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Data e Hora'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                      ),
                      onTap: () => _selectDate(context),
                      trailing: const Icon(Icons.edit_outlined),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
