import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';

enum RecurrenceType { none, daily, weekly, monthly }

class RecurringAppointmentDialog extends StatefulWidget {
  final Function(List<Appointment>) onAppointmentsCreated;

  const RecurringAppointmentDialog({
    super.key,
    required this.onAppointmentsCreated,
  });

  @override
  State<RecurringAppointmentDialog> createState() =>
      _RecurringAppointmentDialogState();
}

class _RecurringAppointmentDialogState
    extends State<RecurringAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  RecurrenceType _recurrenceType = RecurrenceType.none;
  int _interval = 1;
  int _occurrences = 1;
  DateTime? _endDate;

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
      title: const Text('Agendamento Recorrente'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dados básicos
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
                    if (double.tryParse(value!) == null) {
                      return 'Preço inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Data e hora
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(_startDate)}',
                        ),
                        leading: const Icon(Icons.calendar_today),
                        onTap: _selectStartDate,
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

                // Configurações de recorrência
                const Divider(),
                const Text(
                  'Configurações de Recorrência',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Recorrência',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: RecurrenceType.none,
                      child: Text('Sem recorrência'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceType.daily,
                      child: Text('Diário'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceType.weekly,
                      child: Text('Semanal'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceType.monthly,
                      child: Text('Mensal'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _recurrenceType = value!),
                ),

                if (_recurrenceType != RecurrenceType.none) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _interval.toString(),
                          decoration: InputDecoration(
                            labelText: 'Intervalo',
                            helperText: _getIntervalHelperText(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              _interval = int.tryParse(value) ?? 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _occurrences.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Número de Ocorrências',
                            helperText: 'Quantas vezes repetir',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              _occurrences = int.tryParse(value) ?? 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      _endDate == null
                          ? 'Data Final: Não definida'
                          : 'Data Final: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                    ),
                    leading: const Icon(Icons.event),
                    trailing: _endDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _endDate = null),
                          )
                        : null,
                    onTap: _selectEndDate,
                  ),
                ],

                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
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
          onPressed: _createRecurringAppointments,
          child: const Text('Criar Agendamentos'),
        ),
      ],
    );
  }

  String _getIntervalHelperText() {
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        return 'A cada X dias';
      case RecurrenceType.weekly:
        return 'A cada X semanas';
      case RecurrenceType.monthly:
        return 'A cada X meses';
      default:
        return '';
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
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

  void _createRecurringAppointments() {
    if (!_formKey.currentState!.validate()) return;

    final appointments = <Appointment>[];
    final baseDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (_recurrenceType == RecurrenceType.none) {
      // Agendamento único
      appointments.add(_createAppointment(baseDateTime, 0));
    } else {
      // Agendamentos recorrentes
      final dates = _generateRecurringDates(baseDateTime);
      for (int i = 0; i < dates.length; i++) {
        appointments.add(_createAppointment(dates[i], i));
      }
    }

    widget.onAppointmentsCreated(appointments);
    Navigator.pop(context);
  }

  List<DateTime> _generateRecurringDates(DateTime startDate) {
    final dates = <DateTime>[];
    DateTime currentDate = startDate;

    for (int i = 0; i < _occurrences; i++) {
      if (_endDate != null && currentDate.isAfter(_endDate!)) break;

      dates.add(currentDate);

      switch (_recurrenceType) {
        case RecurrenceType.daily:
          currentDate = currentDate.add(Duration(days: _interval));
          break;
        case RecurrenceType.weekly:
          currentDate = currentDate.add(Duration(days: 7 * _interval));
          break;
        case RecurrenceType.monthly:
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + _interval,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RecurrenceType.none:
          break;
      }
    }

    return dates;
  }

  Appointment _createAppointment(DateTime dateTime, int index) {
    return Appointment(
      id: '${DateTime.now().millisecondsSinceEpoch}_$index',
      professionalId: '1', // Mock professional ID
      serviceId: '1', // Mock service ID
      dateTime: dateTime,
      clientName: _clientNameController.text,
      clientPhone: _clientPhoneController.text,
      serviceName: _serviceController.text,
      price: double.parse(_priceController.text),
      status: AppointmentStatus.scheduled,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      confirmedByClient: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
