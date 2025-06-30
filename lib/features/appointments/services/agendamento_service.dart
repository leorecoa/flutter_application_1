import '../models/agendamento_model.dart';

class AgendamentoService {
  static final List<Agendamento> _agendamentos = [];

  static Future<List<Agendamento>> getAgendamentos() async {
    return List.from(_agendamentos);
  }

  static List<({String id, String nome})> getBarbeiros() {
    return [
      (id: 'barbeiro-1', nome: 'Carlos'),
      (id: 'barbeiro-2', nome: 'Ana'),
    ];
  }

  static List<({String id, String nome})> getClientes() {
    return [
      (id: 'cliente-1', nome: 'João Silva'),
      (id: 'cliente-2', nome: 'Maria Santos'),
    ];
  }

  static List<({String id, String nome, double valor})> getServicos() {
    return [
      (id: 'servico-1', nome: 'Corte Masculino', valor: 35.0),
      (id: 'servico-2', nome: 'Corte + Escova', valor: 65.0),
    ];
  }

  static Future<Agendamento> criarAgendamento(Agendamento agendamento) async {
    final novoAgendamento = agendamento.copyWith(
      id: 'agend-${DateTime.now().millisecondsSinceEpoch}',
    );
    _agendamentos.add(novoAgendamento);
    return novoAgendamento;
  }

  static Future<Agendamento> atualizarAgendamento(Agendamento agendamento) async {
    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
    }
    return agendamento;
  }

  static Future<void> cancelarAgendamento(String id) async {
    final index = _agendamentos.indexWhere((a) => a.id == id);
    if (index != -1) {
      _agendamentos[index] = _agendamentos[index].copyWith(
        status: StatusAgendamento.cancelado,
      );
    }
  }
}