import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';

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
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '(11) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: Validators.phone,
                onChanged: (value) {
                  final formatted = InputFormatters.formatPhone(value);
                  if (formatted != value) {
                    _clientPhoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText: 'Serviço',
                  prefixIcon: Icon(Icons.content_cut),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => Validators.required(value, 'Serviço'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: Validators.price,
                onChanged: (value) {
                  final formatted = InputFormatters.formatPrice(value);
                  if (formatted != value) {
                    _priceController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Data e Hora'),
                  subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year} às ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.event),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectDateTime,
                ),
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
        LoadingButton(
          isLoading: _isLoading,
          onPressed: _saveAppointment,
          text: 'Salvar Agendamento',
          icon: Icons.save,
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
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appointment = await _appointmentsService.createAppointment(
        clientName: _clientNameController.text,
        clientPhone: _clientPhoneController.text,
        service: _serviceController.text,
        dateTime: _selectedDate,
        price: double.parse(_priceController.text),
      );

      widget.onAppointmentAdded(appointment);
      
      if (mounted) {
        Navigator.of(context).pop();
        SuccessSnackBar.show(context, 'Agendamento criado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorSnackBar.show(context, 'Erro ao criar agendamento: ${e.toString()}');
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