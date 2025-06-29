import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';

class AgendamentoForm extends StatefulWidget {
  final Agendamento? agendamento;
  final VoidCallback onSaved;

  const AgendamentoForm({
    super.key,
    this.agendamento,
    required this.onSaved,
  });

  @override
  State<AgendamentoForm> createState() => _AgendamentoFormState();
}

class _AgendamentoFormState extends State<AgendamentoForm> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  Cliente? _clienteSelecionado;
  Servico? _servicoSelecionado;
  Barbeiro? _barbeiroSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  
  List<Cliente> _clientes = [];
  // List<Cliente> _clientesFiltrados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.agendamento != null) {
      _preencherFormulario();
    }
  }

  void _loadData() async {
    _clientes = await AgendamentoService.getClientes();
    // _clientesFiltrados = _clientes;
    setState(() {});
  }

  void _preencherFormulario() {
    final agendamento = widget.agendamento!;
    _clienteController.text = agendamento.clienteNome;
    _clienteSelecionado = Cliente(
      id: agendamento.clienteId,
      nome: agendamento.clienteNome,
      telefone: '',
      email: '',
    );
    _dataSelecionada = agendamento.dataHora;
    _horaSelecionada = TimeOfDay.fromDateTime(agendamento.dataHora);
    _observacoesController.text = agendamento.observacoes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Flexible(child: _buildForm()),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.agendamento == null ? 'Novo Agendamento' : 'Editar Agendamento',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildClienteField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildServicoField()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarbeiroField()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDataField()),
              const SizedBox(width: 16),
              Expanded(child: _buildHoraField()),
            ],
          ),
          const SizedBox(height: 16),
          _buildObservacoesField(),
        ],
      ),
    );
  }

  Widget _buildClienteField() {
    return Autocomplete<Cliente>(
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) return _clientes;
        return await AgendamentoService.getClientes(textEditingValue.text);
      },
      displayStringForOption: (cliente) => cliente.nome,
      onSelected: (cliente) {
        _clienteSelecionado = cliente;
        _clienteController.text = cliente.nome;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        _clienteController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Cliente',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => value?.isEmpty == true ? 'Selecione um cliente' : null,
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }

  Widget _buildServicoField() {
    return DropdownButtonFormField<Servico>(
      value: _servicoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Serviço',
        prefixIcon: Icon(Icons.content_cut_outlined),
      ),
      items: AgendamentoService.getServicos().map((servico) {
        return DropdownMenuItem(
          value: servico,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(servico.nome),
              Text(
                'R\$ ${servico.preco.toStringAsFixed(2)} - ${servico.duracaoMinutos}min',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (servico) => setState(() => _servicoSelecionado = servico),
      validator: (value) => value == null ? 'Selecione um serviço' : null,
    );
  }

  Widget _buildBarbeiroField() {
    return DropdownButtonFormField<Barbeiro>(
      value: _barbeiroSelecionado,
      decoration: const InputDecoration(
        labelText: 'Barbeiro',
        prefixIcon: Icon(Icons.person_pin_outlined),
      ),
      items: AgendamentoService.getBarbeiros().map((barbeiro) {
        return DropdownMenuItem(
          value: barbeiro,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(barbeiro.nome),
              Text(
                barbeiro.especialidade,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (barbeiro) => setState(() => _barbeiroSelecionado = barbeiro),
      validator: (value) => value == null ? 'Selecione um barbeiro' : null,
    );
  }

  Widget _buildDataField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data',
        prefixIcon: Icon(Icons.calendar_today_outlined),
      ),
      controller: TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_dataSelecionada),
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _dataSelecionada,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (data != null) {
          setState(() => _dataSelecionada = data);
        }
      },
    );
  }

  Widget _buildHoraField() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Hora',
        prefixIcon: Icon(Icons.access_time_outlined),
      ),
      controller: TextEditingController(
        text: _horaSelecionada.format(context),
      ),
      onTap: () async {
        final hora = await showTimePicker(
          context: context,
          initialTime: _horaSelecionada,
        );
        if (hora != null) {
          setState(() => _horaSelecionada = hora);
        }
      },
    );
  }

  Widget _buildObservacoesField() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        prefixIcon: Icon(Icons.notes_outlined),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarAgendamento,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.agendamento == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }

  void _salvarAgendamento() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteSelecionado == null) return;

    setState(() => _isLoading = true);

    final dataHora = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    final agendamento = Agendamento(
      id: widget.agendamento?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clienteNome: _clienteSelecionado!.nome,
      clienteId: _clienteSelecionado!.id,
      servicoNome: _servicoSelecionado!.nome,
      servicoId: _servicoSelecionado!.id,
      barbeiroNome: _barbeiroSelecionado!.nome,
      barbeiroId: _barbeiroSelecionado!.id,
      dataHora: dataHora,
      status: widget.agendamento?.status ?? StatusAgendamento.confirmado,
      valor: _servicoSelecionado!.preco,
      observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
    );

    try {
      if (widget.agendamento == null) {
        await AgendamentoService.criarAgendamento(agendamento);
      } else {
        await AgendamentoService.atualizarAgendamento(agendamento);
      }
      
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}