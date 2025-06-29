import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/agendamento_model.dart';
import '../services/agendamento_service.dart';
import '../widgets/agendamento_table.dart';
import '../widgets/simple_agendamento_form.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final _buscaController = TextEditingController();
  List<Agendamento> _agendamentos = [];
  bool _isLoading = false;
  
  String? _filtroBarbeiro;
  StatusAgendamento? _filtroStatus;
  DateTime? _filtroData;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
    _buscaController.addListener(_onBuscaChanged);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _onBuscaChanged() {
    _carregarAgendamentos();
  }

  void _carregarAgendamentos() async {
    setState(() => _isLoading = true);
    
    final agendamentos = await AgendamentoService.getAgendamentos(
      filtroCliente: _buscaController.text,
      filtroBarbeiro: _filtroBarbeiro,
      filtroStatus: _filtroStatus,
      filtroData: _filtroData,
    );
    
    setState(() {
      _agendamentos = agendamentos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Agendamentos',
      currentRoute: '/admin/appointments',
      floatingActionButton: FloatingActionButton(
        onPressed: _novoAgendamento,
        backgroundColor: TrinksTheme.navyBlue,
        child: const Icon(Icons.add, color: TrinksTheme.white),
      ),
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: AgendamentoTable(
              agendamentos: _agendamentos,
              isLoading: _isLoading,
              onEdit: _editarAgendamento,
              onCancel: _cancelarAgendamento,
              onComplete: _concluirAgendamento,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: _buildBuscaField()),
              const SizedBox(width: 16),
              Expanded(child: _buildDataFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarbeiroFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusFilter()),
              const SizedBox(width: 16),
              _buildLimparFiltros(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuscaField() {
    return TextField(
      controller: _buscaController,
      decoration: const InputDecoration(
        hintText: 'Buscar por cliente...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDataFilter() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Filtrar por data',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: _filtroData != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _filtroData = null);
                  _carregarAgendamentos();
                },
              )
            : null,
      ),
      controller: TextEditingController(
        text: _filtroData != null ? DateFormat('dd/MM/yyyy').format(_filtroData!) : '',
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _filtroData ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (data != null) {
          setState(() => _filtroData = data);
          _carregarAgendamentos();
        }
      },
    );
  }

  Widget _buildBarbeiroFilter() {
    return DropdownButtonFormField<String>(
      value: _filtroBarbeiro,
      decoration: const InputDecoration(
        hintText: 'Filtrar por barbeiro',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos os barbeiros')),
        ...AgendamentoService.getBarbeiros().map((barbeiro) {
          return DropdownMenuItem(
            value: barbeiro.id,
            child: Text(barbeiro.nome),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _filtroBarbeiro = value);
        _carregarAgendamentos();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<StatusAgendamento>(
      value: _filtroStatus,
      decoration: const InputDecoration(
        hintText: 'Filtrar por status',
        prefixIcon: Icon(Icons.filter_list_outlined),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos os status')),
        DropdownMenuItem(value: StatusAgendamento.confirmado, child: Text('Confirmado')),
        DropdownMenuItem(value: StatusAgendamento.pendente, child: Text('Pendente')),
        DropdownMenuItem(value: StatusAgendamento.cancelado, child: Text('Cancelado')),
        DropdownMenuItem(value: StatusAgendamento.concluido, child: Text('Concluído')),
      ],
      onChanged: (value) {
        setState(() => _filtroStatus = value);
        _carregarAgendamentos();
      },
    );
  }

  Widget _buildLimparFiltros() {
    return ElevatedButton.icon(
      onPressed: _limparFiltros,
      icon: const Icon(Icons.clear_all),
      label: const Text('Limpar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: TrinksTheme.lightGray,
        foregroundColor: TrinksTheme.darkGray,
      ),
    );
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroBarbeiro = null;
      _filtroStatus = null;
      _filtroData = null;
    });
    _carregarAgendamentos();
  }

  void _novoAgendamento() {
    showDialog(
      context: context,
      builder: (context) => SimpleAgendamentoForm(
        onSaved: _carregarAgendamentos,
      ),
    );
  }

  void _editarAgendamento(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => SimpleAgendamentoForm(
        agendamento: agendamento,
        onSaved: _carregarAgendamentos,
      ),
    );
  }

  void _cancelarAgendamento(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Tem certeza que deseja cancelar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await AgendamentoService.cancelarAgendamento(id);
              _carregarAgendamentos();
            },
            style: ElevatedButton.styleFrom(backgroundColor: TrinksTheme.error),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _concluirAgendamento(String id) async {
    final agendamento = _agendamentos.firstWhere((a) => a.id == id);
    final agendamentoAtualizado = agendamento.copyWith(status: StatusAgendamento.concluido);
    await AgendamentoService.atualizarAgendamento(agendamentoAtualizado);
    _carregarAgendamentos();
  }
}