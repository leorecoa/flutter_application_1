import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../models/agendamento_model.dart';

class AddAppointmentDialog extends StatefulWidget {
  final Function(Agendamento) onSave;

  const AddAppointmentDialog({required this.onSave, super.key});

  @override
  State<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _barbeiroController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Novo Agendamento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: LuxuryTheme.deepBlue,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servicoController,
                decoration: const InputDecoration(
                  labelText: 'Serviço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barbeiroController,
                decoration: const InputDecoration(
                  labelText: 'Profissional',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                          'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Hora: ${_selectedTime.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveAgendamento,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
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

  void _saveAgendamento() {
    if (_formKey.currentState!.validate()) {
      final agendamento = Agendamento(
        id: '',
        clienteNome: _clienteController.text,
        clienteId: 'cliente-${DateTime.now().millisecondsSinceEpoch}',
        servicoNome: _servicoController.text,
        servicoId: 'servico-${DateTime.now().millisecondsSinceEpoch}',
        barbeiroNome: _barbeiroController.text,
        barbeiroId: 'barbeiro-${DateTime.now().millisecondsSinceEpoch}',
        dataHora: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        valor: double.tryParse(_valorController.text) ?? 0.0,
        status: StatusAgendamento.pendente,
      );

      widget.onSave(agendamento);
      Navigator.pop(context);
    }
  }
}
