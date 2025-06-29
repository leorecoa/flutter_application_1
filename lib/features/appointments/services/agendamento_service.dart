import '../models/agendamento_model.dart';

class AgendamentoService {
  static final List<Agendamento> _agendamentos = [
    Agendamento(
      id: '1',
      clienteNome: 'João Silva',
      clienteId: '1',
      servicoNome: 'Corte + Barba',
      servicoId: '1',
      barbeiroNome: 'Carlos',
      barbeiroId: '1',
      dataHora: DateTime.now().add(const Duration(hours: 2)),
      status: StatusAgendamento.confirmado,
      valor: 55.0,
    ),
    Agendamento(
      id: '2',
      clienteNome: 'Pedro Costa',
      clienteId: '2',
      servicoNome: 'Corte',
      servicoId: '2',
      barbeiroNome: 'Roberto',
      barbeiroId: '2',
      dataHora: DateTime.now().add(const Duration(hours: 4)),
      status: StatusAgendamento.pendente,
      valor: 35.0,
    ),
    Agendamento(
      id: '3',
      clienteNome: 'Maria Santos',
      clienteId: '3',
      servicoNome: 'Sobrancelha',
      servicoId: '3',
      barbeiroNome: 'Ana',
      barbeiroId: '3',
      dataHora: DateTime.now().subtract(const Duration(hours: 1)),
      status: StatusAgendamento.concluido,
      valor: 15.0,
    ),
  ];

  static final List<Cliente> _clientes = [
    const Cliente(id: '1', nome: 'João Silva', telefone: '(11) 99999-9999', email: 'joao@email.com'),
    const Cliente(id: '2', nome: 'Pedro Costa', telefone: '(11) 88888-8888', email: 'pedro@email.com'),
    const Cliente(id: '3', nome: 'Maria Santos', telefone: '(11) 77777-7777', email: 'maria@email.com'),
    const Cliente(id: '4', nome: 'Carlos Oliveira', telefone: '(11) 66666-6666', email: 'carlos@email.com'),
  ];

  static final List<Servico> _servicos = [
    const Servico(id: '1', nome: 'Corte + Barba', preco: 55.0, duracaoMinutos: 60),
    const Servico(id: '2', nome: 'Corte', preco: 35.0, duracaoMinutos: 45),
    const Servico(id: '3', nome: 'Barba', preco: 25.0, duracaoMinutos: 30),
    const Servico(id: '4', nome: 'Sobrancelha', preco: 15.0, duracaoMinutos: 15),
  ];

  static final List<Barbeiro> _barbeiros = [
    const Barbeiro(id: '1', nome: 'Carlos', especialidade: 'Corte Masculino'),
    const Barbeiro(id: '2', nome: 'Roberto', especialidade: 'Barba'),
    const Barbeiro(id: '3', nome: 'Ana', especialidade: 'Sobrancelha'),
  ];

  static Future<List<Agendamento>> getAgendamentos({
    String? filtroCliente,
    String? filtroBarbeiro,
    StatusAgendamento? filtroStatus,
    DateTime? filtroData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var result = List<Agendamento>.from(_agendamentos);
    
    if (filtroCliente != null && filtroCliente.isNotEmpty) {
      result = result.where((a) => a.clienteNome.toLowerCase().contains(filtroCliente.toLowerCase())).toList();
    }
    
    if (filtroBarbeiro != null && filtroBarbeiro.isNotEmpty) {
      result = result.where((a) => a.barbeiroId == filtroBarbeiro).toList();
    }
    
    if (filtroStatus != null) {
      result = result.where((a) => a.status == filtroStatus).toList();
    }
    
    if (filtroData != null) {
      result = result.where((a) => 
        a.dataHora.year == filtroData.year &&
        a.dataHora.month == filtroData.month &&
        a.dataHora.day == filtroData.day
      ).toList();
    }
    
    return result;
  }

  static Future<List<Cliente>> getClientes([String? busca]) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (busca == null || busca.isEmpty) return _clientes;
    return _clientes.where((c) => c.nome.toLowerCase().contains(busca.toLowerCase())).toList();
  }

  static List<Servico> getServicos() => _servicos;
  static List<Barbeiro> getBarbeiros() => _barbeiros;

  static Future<void> criarAgendamento(Agendamento agendamento) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _agendamentos.add(agendamento);
  }

  static Future<void> atualizarAgendamento(Agendamento agendamento) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
    }
  }

  static Future<void> cancelarAgendamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _agendamentos.indexWhere((a) => a.id == id);
    if (index != -1) {
      _agendamentos[index] = _agendamentos[index].copyWith(status: StatusAgendamento.cancelado);
    }
  }
}