import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';

class SimpleAgendamentoForm extends StatefulWidget {
  final Agendamento? agendamento;
  final VoidCallback onSaved;

  const SimpleAgendamentoForm({
    super.key,
    this.agendamento,
    required this.onSaved,
  });

  @override
  State<SimpleAgendamentoForm> createState() => _SimpleAgendamentoFormState();
}

class _SimpleAgendamentoFormState extends State<SimpleAgendamentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _valorController = TextEditingController();

  String _barbeiroSelecionado = 'barbeiro-1';
  DateTime _dataHora = DateTime.now().add(const Duration(hours: 1));
  StatusAgendamento _status = StatusAgendamento.pendente;

  @override
  void initState() {
    super.initState();
    if (widget.agendamento != null) {
      _loadData();
    }
  }

  void _loadData() {
    final agendamento = widget.agendamento!;
    _clienteController.text = agendamento.clienteNome;
    _servicoController.text = agendamento.servicoNome;
    _valorController.text = agendamento.valor.toString();
    _barbeiroSelecionado = agendamento.barbeiroId;
    _dataHora = agendamento.dataHora;
    _status = agendamento.status;
  }

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
              Text(
                widget.agendamento == null
                    ? 'Novo Agendamento'
                    : 'Editar Agendamento',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _barbeiroSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Profissional',
                        border: OutlineInputBorder(),
                      ),
                      items: AgendamentoService.getBarbeiros().map((barbeiro) {
                        return DropdownMenuItem(
                          value: barbeiro.id,
                          child: Text(barbeiro.nome),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _barbeiroSelecionado = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                          'Data: ${_dataHora.day}/${_dataHora.month}/${_dataHora.year}'),
                      subtitle: Text(
                          'Hora: ${_dataHora.hour}:${_dataHora.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDateTime,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<StatusAgendamento>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: StatusAgendamento.pendente,
                            child: Text('Pendente')),
                        DropdownMenuItem(
                            value: StatusAgendamento.confirmado,
                            child: Text('Confirmado')),
                        DropdownMenuItem(
                            value: StatusAgendamento.concluido,
                            child: Text('Concluído')),
                        DropdownMenuItem(
                            value: StatusAgendamento.cancelado,
                            child: Text('Cancelado')),
                      ],
                      onChanged: (value) => setState(() => _status = value!),
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
                    onPressed: _save,
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

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dataHora),
      );

      if (time != null) {
        setState(() {
          _dataHora =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final barbeiro = AgendamentoService.getBarbeiros()
          .firstWhere((b) => b.id == _barbeiroSelecionado);

      final agendamento = Agendamento(
        id: widget.agendamento?.id ?? '',
        clienteNome: _clienteController.text,
        clienteId: 'cliente-${DateTime.now().millisecondsSinceEpoch}',
        servicoNome: _servicoController.text,
        servicoId: 'servico-${DateTime.now().millisecondsSinceEpoch}',
        barbeiroNome: barbeiro.nome,
        barbeiroId: barbeiro.id,
        dataHora: _dataHora,
        valor: double.tryParse(_valorController.text) ?? 0.0,
        status: _status,
      );

      if (widget.agendamento == null) {
        await AgendamentoService.criarAgendamento(agendamento);
      } else {
        await AgendamentoService.atualizarAgendamento(agendamento);
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    }
  }
}
