enum FormaPagamento { pix, dinheiro, cartao }
enum StatusPagamento { pago, pendente, cancelado }

class Payment {
  final String id;
  final String clienteNome;
  final String clienteId;
  final String servicoNome;
  final String servicoId;
  final String barbeiroNome;
  final String barbeiroId;
  final double valor;
  final FormaPagamento formaPagamento;
  final StatusPagamento status;
  final DateTime data;
  final String? observacoes;
  final String? chavePix;
  final String? agendamentoId;

  const Payment({
    required this.id,
    required this.clienteNome,
    required this.clienteId,
    required this.servicoNome,
    required this.servicoId,
    required this.barbeiroNome,
    required this.barbeiroId,
    required this.valor,
    required this.formaPagamento,
    required this.status,
    required this.data,
    this.observacoes,
    this.chavePix,
    this.agendamentoId,
  });

  Payment copyWith({
    String? id,
    String? clienteNome,
    String? clienteId,
    String? servicoNome,
    String? servicoId,
    String? barbeiroNome,
    String? barbeiroId,
    double? valor,
    FormaPagamento? formaPagamento,
    StatusPagamento? status,
    DateTime? data,
    String? observacoes,
    String? chavePix,
    String? agendamentoId,
  }) {
    return Payment(
      id: id ?? this.id,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteId: clienteId ?? this.clienteId,
      servicoNome: servicoNome ?? this.servicoNome,
      servicoId: servicoId ?? this.servicoId,
      barbeiroNome: barbeiroNome ?? this.barbeiroNome,
      barbeiroId: barbeiroId ?? this.barbeiroId,
      valor: valor ?? this.valor,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      status: status ?? this.status,
      data: data ?? this.data,
      observacoes: observacoes ?? this.observacoes,
      chavePix: chavePix ?? this.chavePix,
      agendamentoId: agendamentoId ?? this.agendamentoId,
    );
  }
}

class RelatorioFinanceiro {
  final double totalRecebido;
  final double totalPendente;
  final Map<String, double> receitaPorBarbeiro;
  final Map<FormaPagamento, double> receitaPorFormaPagamento;
  final int totalTransacoes;

  const RelatorioFinanceiro({
    required this.totalRecebido,
    required this.totalPendente,
    required this.receitaPorBarbeiro,
    required this.receitaPorFormaPagamento,
    required this.totalTransacoes,
  });
}