import 'dart:convert';
import '../models/agendamento_model.dart';
import '../../../core/services/api_client.dart';
import '../../../core/config/aws_config.dart';

class AgendamentoService {
  static final List<Agendamento> _agendamentos = [
    Agendamento(
      id: '1',
      clienteNome: 'João Silva',
      clienteId: 'cliente-1',
      servicoNome: 'Corte Masculino',
      servicoId: 'servico-1',
      barbeiroNome: 'Carlos',
      barbeiroId: 'barbeiro-1',
      dataHora: DateTime.now().add(const Duration(hours: 2)),
      valor: 35.0,
      status: StatusAgendamento.confirmado,
    ),
    Agendamento(
      id: '2',
      clienteNome: 'Maria Santos',
      clienteId: 'cliente-2',
      servicoNome: 'Corte + Escova',
      servicoId: 'servico-2',
      barbeiroNome: 'Ana',
      barbeiroId: 'barbeiro-2',
      dataHora: DateTime.now().add(const Duration(hours: 4)),
      valor: 65.0,
      status: StatusAgendamento.pendente,
    ),
  ];

  static Future<List<Agendamento>> getAgendamentos({
    String? filtroCliente,
    String? filtroBarbeiro,
    StatusAgendamento? filtroStatus,
    DateTime? filtroData,
  }) async {
    if (!AuthService.isAuthenticated) {
      return List.from(_agendamentos);
    }
    
    try {
      final response = await ApiClient.get(AWSConfig.agendamentosEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Agendamento.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback para dados locais
    }
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
    if (AuthService.isAuthenticated) {
      try {
        final agendamentoData = agendamento.toJson();
        agendamentoData['userId'] = AuthService.userId;
        
        final response = await ApiClient.post(
          AWSConfig.agendamentosEndpoint,
          agendamentoData,
        );
        if (response.statusCode == 201) {
          return Agendamento.fromJson(json.decode(response.body));
        }
      } catch (e) {
        // Fallback para dados locais
      }
    }
    
    final novoAgendamento = agendamento.copyWith(
      id: 'agend-${DateTime.now().millisecondsSinceEpoch}',
    );
    _agendamentos.add(novoAgendamento);
    return novoAgendamento;
  }

  static Future<Agendamento> atualizarAgendamento(Agendamento agendamento) async {
    try {
      final response = await ApiClient.put(
        '${AWSConfig.agendamentosEndpoint}/${agendamento.id}',
        agendamento.toJson(),
      );
      if (response.statusCode == 200) {
        return Agendamento.fromJson(json.decode(response.body));
      }
    } catch (e) {
      // Fallback para dados locais
    }
    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
    }
    return agendamento;
  }

  static Future<void> cancelarAgendamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _agendamentos.indexWhere((a) => a.id == id);
    if (index != -1) {
      _agendamentos[index] = _agendamentos[index].copyWith(
        status: StatusAgendamento.cancelado,
      );
    }
  }

  static Future<void> concluirAgendamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _agendamentos.indexWhere((a) => a.id == id);
    if (index != -1) {
      _agendamentos[index] = _agendamentos[index].copyWith(
        status: StatusAgendamento.concluido,
      );
    }
  }
}