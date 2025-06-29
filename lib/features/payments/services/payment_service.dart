import '../models/payment_model.dart';
import '../../appointments/models/agendamento_model.dart';
import '../../recibo_automatico/services/recibo_service.dart';

class PaymentService {
  static List<Payment> _payments = [
    Payment(
      id: '1',
      clienteNome: 'João Silva',
      clienteId: '1',
      servicoNome: 'Corte + Barba',
      servicoId: '1',
      barbeiroNome: 'Carlos',
      barbeiroId: '1',
      valor: 55.0,
      formaPagamento: FormaPagamento.pix,
      status: StatusPagamento.pago,
      data: DateTime.now().subtract(const Duration(hours: 2)),
      chavePix: 'carlos@barbearia.com',
    ),
    Payment(
      id: '2',
      clienteNome: 'Pedro Costa',
      clienteId: '2',
      servicoNome: 'Corte',
      servicoId: '2',
      barbeiroNome: 'Roberto',
      barbeiroId: '2',
      valor: 35.0,
      formaPagamento: FormaPagamento.dinheiro,
      status: StatusPagamento.pago,
      data: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Payment(
      id: '3',
      clienteNome: 'Maria Santos',
      clienteId: '3',
      servicoNome: 'Sobrancelha',
      servicoId: '3',
      barbeiroNome: 'Ana',
      barbeiroId: '3',
      valor: 15.0,
      formaPagamento: FormaPagamento.cartao,
      status: StatusPagamento.pendente,
      data: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Payment(
      id: '4',
      clienteNome: 'Carlos Oliveira',
      clienteId: '4',
      servicoNome: 'Barba',
      servicoId: '4',
      barbeiroNome: 'Carlos',
      barbeiroId: '1',
      valor: 25.0,
      formaPagamento: FormaPagamento.pix,
      status: StatusPagamento.cancelado,
      data: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static Future<List<Payment>> getPayments({
    String? filtroCliente,
    String? filtroBarbeiro,
    FormaPagamento? filtroFormaPagamento,
    StatusPagamento? filtroStatus,
    DateTime? filtroDataInicio,
    DateTime? filtroDataFim,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var result = List<Payment>.from(_payments);
    
    if (filtroCliente != null && filtroCliente.isNotEmpty) {
      result = result.where((p) => p.clienteNome.toLowerCase().contains(filtroCliente.toLowerCase())).toList();
    }
    
    if (filtroBarbeiro != null && filtroBarbeiro.isNotEmpty) {
      result = result.where((p) => p.barbeiroId == filtroBarbeiro).toList();
    }
    
    if (filtroFormaPagamento != null) {
      result = result.where((p) => p.formaPagamento == filtroFormaPagamento).toList();
    }
    
    if (filtroStatus != null) {
      result = result.where((p) => p.status == filtroStatus).toList();
    }
    
    if (filtroDataInicio != null) {
      result = result.where((p) => p.data.isAfter(filtroDataInicio.subtract(const Duration(days: 1)))).toList();
    }
    
    if (filtroDataFim != null) {
      result = result.where((p) => p.data.isBefore(filtroDataFim.add(const Duration(days: 1)))).toList();
    }
    
    return result..sort((a, b) => b.data.compareTo(a.data));
  }

  static Future<void> criarPagamento(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _payments.add(payment);
    
    // Se o pagamento já foi criado como pago, enviar recibo
    if (payment.status == StatusPagamento.pago) {
      ReciboService.processarPagamentoConfirmado(payment);
    }
  }

  static Future<void> atualizarPagamento(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      final paymentAnterior = _payments[index];
      _payments[index] = payment;
      
      // Se o pagamento foi confirmado (mudou de pendente para pago)
      if (paymentAnterior.status != StatusPagamento.pago && 
          payment.status == StatusPagamento.pago) {
        // Enviar recibo automaticamente
        ReciboService.processarPagamentoConfirmado(payment);
      }
    }
  }

  static Future<void> cancelarPagamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(status: StatusPagamento.cancelado);
    }
  }

  static Future<RelatorioFinanceiro> getRelatorioFinanceiro({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    var payments = _payments;
    
    if (dataInicio != null) {
      payments = payments.where((p) => p.data.isAfter(dataInicio.subtract(const Duration(days: 1)))).toList();
    }
    
    if (dataFim != null) {
      payments = payments.where((p) => p.data.isBefore(dataFim.add(const Duration(days: 1)))).toList();
    }

    final pagoPayments = payments.where((p) => p.status == StatusPagamento.pago).toList();
    final pendentePayments = payments.where((p) => p.status == StatusPagamento.pendente).toList();
    
    final totalRecebido = pagoPayments.fold(0.0, (sum, p) => sum + p.valor);
    final totalPendente = pendentePayments.fold(0.0, (sum, p) => sum + p.valor);
    
    final receitaPorBarbeiro = <String, double>{};
    final receitaPorFormaPagamento = <FormaPagamento, double>{};
    
    for (final payment in pagoPayments) {
      receitaPorBarbeiro[payment.barbeiroNome] = (receitaPorBarbeiro[payment.barbeiroNome] ?? 0) + payment.valor;
      receitaPorFormaPagamento[payment.formaPagamento] = (receitaPorFormaPagamento[payment.formaPagamento] ?? 0) + payment.valor;
    }
    
    return RelatorioFinanceiro(
      totalRecebido: totalRecebido,
      totalPendente: totalPendente,
      receitaPorBarbeiro: receitaPorBarbeiro,
      receitaPorFormaPagamento: receitaPorFormaPagamento,
      totalTransacoes: payments.length,
    );
  }

  static List<Cliente> getClientes() {
    return [
      const Cliente(id: '1', nome: 'João Silva', telefone: '(11) 99999-9999', email: 'joao@email.com'),
      const Cliente(id: '2', nome: 'Pedro Costa', telefone: '(11) 88888-8888', email: 'pedro@email.com'),
      const Cliente(id: '3', nome: 'Maria Santos', telefone: '(11) 77777-7777', email: 'maria@email.com'),
      const Cliente(id: '4', nome: 'Carlos Oliveira', telefone: '(11) 66666-6666', email: 'carlos@email.com'),
    ];
  }

  static List<Servico> getServicos() {
    return [
      const Servico(id: '1', nome: 'Corte + Barba', preco: 55.0, duracaoMinutos: 60),
      const Servico(id: '2', nome: 'Corte', preco: 35.0, duracaoMinutos: 45),
      const Servico(id: '3', nome: 'Barba', preco: 25.0, duracaoMinutos: 30),
      const Servico(id: '4', nome: 'Sobrancelha', preco: 15.0, duracaoMinutos: 15),
    ];
  }

  static List<Barbeiro> getBarbeiros() {
    return [
      const Barbeiro(id: '1', nome: 'Carlos', especialidade: 'Corte Masculino'),
      const Barbeiro(id: '2', nome: 'Roberto', especialidade: 'Barba'),
      const Barbeiro(id: '3', nome: 'Ana', especialidade: 'Sobrancelha'),
    ];
  }
}