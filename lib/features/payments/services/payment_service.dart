import '../models/payment_model.dart';

class PaymentService {
  static final List<Payment> _payments = [
    Payment(
      id: 'pay-1',
      clienteId: 'cliente-1',
      clienteNome: 'João Silva',
      servicoId: 'servico-1',
      servicoNome: 'Corte Masculino',
      barbeiroId: 'barbeiro-1',
      barbeiroNome: 'Carlos',
      valor: 35.0,
      formaPagamento: FormaPagamento.pix,
      data: DateTime.now().subtract(const Duration(hours: 2)),
      status: StatusPagamento.pago,
      chavePix: 'joao@email.com',
    ),
    Payment(
      id: 'pay-2',
      clienteId: 'cliente-2',
      clienteNome: 'Maria Santos',
      servicoId: 'servico-2',
      servicoNome: 'Corte + Escova',
      barbeiroId: 'barbeiro-2',
      barbeiroNome: 'Ana',
      valor: 65.0,
      formaPagamento: FormaPagamento.cartao,
      data: DateTime.now().subtract(const Duration(hours: 4)),
      status: StatusPagamento.pendente,
    ),
  ];

  static Future<List<Payment>> getPayments({
    String? filtroCliente,
    FormaPagamento? filtroFormaPagamento,
    StatusPagamento? filtroStatus,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var payments = List<Payment>.from(_payments);
    
    if (filtroCliente?.isNotEmpty == true) {
      payments = payments.where((p) => 
        p.clienteNome.toLowerCase().contains(filtroCliente!.toLowerCase())
      ).toList();
    }
    
    if (filtroFormaPagamento != null) {
      payments = payments.where((p) => p.formaPagamento == filtroFormaPagamento).toList();
    }
    
    if (filtroStatus != null) {
      payments = payments.where((p) => p.status == filtroStatus).toList();
    }
    
    if (dataInicio != null) {
      payments = payments.where((p) => p.data.isAfter(dataInicio)).toList();
    }
    
    if (dataFim != null) {
      payments = payments.where((p) => p.data.isBefore(dataFim.add(const Duration(days: 1)))).toList();
    }
    
    return payments..sort((a, b) => b.data.compareTo(a.data));
  }

  static Future<Payment> criarPagamento(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final novoPayment = payment.copyWith(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
    );
    _payments.add(novoPayment);
    return novoPayment;
  }

  static Future<Payment> atualizarPagamento(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
    }
    return payment;
  }

  static Future<void> confirmarPagamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: StatusPagamento.pago,
      );
    }
  }

  static Future<void> cancelarPagamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: StatusPagamento.cancelado,
      );
    }
  }

  static Future<Map<String, double>> getResumoFinanceiro() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final hoje = DateTime.now();
    final inicioMes = DateTime(hoje.year, hoje.month, 1);
    
    final pagamentosHoje = _payments.where((p) => 
      p.data.day == hoje.day && 
      p.data.month == hoje.month && 
      p.data.year == hoje.year &&
      p.status == StatusPagamento.pago
    );
    
    final pagamentosMes = _payments.where((p) => 
      p.data.isAfter(inicioMes) &&
      p.status == StatusPagamento.pago
    );
    
    final pendentes = _payments.where((p) => p.status == StatusPagamento.pendente);
    
    return {
      'receitaHoje': pagamentosHoje.fold(0.0, (sum, p) => sum + p.valor),
      'receitaMes': pagamentosMes.fold(0.0, (sum, p) => sum + p.valor),
      'pendentes': pendentes.fold(0.0, (sum, p) => sum + p.valor),
      'ticketMedio': pagamentosMes.isNotEmpty 
        ? pagamentosMes.fold(0.0, (sum, p) => sum + p.valor) / pagamentosMes.length
        : 0.0,
    };
  }
}