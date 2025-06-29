enum StatusAgendamento { confirmado, pendente, cancelado, concluido }

class Agendamento {
  final String id;
  final String clienteNome;
  final String clienteId;
  final String servicoNome;
  final String servicoId;
  final String barbeiroNome;
  final String barbeiroId;
  final DateTime dataHora;
  final StatusAgendamento status;
  final double valor;
  final String? observacoes;

  const Agendamento({
    required this.id,
    required this.clienteNome,
    required this.clienteId,
    required this.servicoNome,
    required this.servicoId,
    required this.barbeiroNome,
    required this.barbeiroId,
    required this.dataHora,
    required this.status,
    required this.valor,
    this.observacoes,
  });

  Agendamento copyWith({
    String? id,
    String? clienteNome,
    String? clienteId,
    String? servicoNome,
    String? servicoId,
    String? barbeiroNome,
    String? barbeiroId,
    DateTime? dataHora,
    StatusAgendamento? status,
    double? valor,
    String? observacoes,
  }) {
    return Agendamento(
      id: id ?? this.id,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteId: clienteId ?? this.clienteId,
      servicoNome: servicoNome ?? this.servicoNome,
      servicoId: servicoId ?? this.servicoId,
      barbeiroNome: barbeiroNome ?? this.barbeiroNome,
      barbeiroId: barbeiroId ?? this.barbeiroId,
      dataHora: dataHora ?? this.dataHora,
      status: status ?? this.status,
      valor: valor ?? this.valor,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}

class Cliente {
  final String id;
  final String nome;
  final String telefone;
  final String email;

  const Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.email,
  });
}

class Servico {
  final String id;
  final String nome;
  final double preco;
  final int duracaoMinutos;

  const Servico({
    required this.id,
    required this.nome,
    required this.preco,
    required this.duracaoMinutos,
  });
}

class Barbeiro {
  final String id;
  final String nome;
  final String especialidade;

  const Barbeiro({
    required this.id,
    required this.nome,
    required this.especialidade,
  });
}