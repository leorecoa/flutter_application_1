import '../../../features/appointments/models/agendamento_model.dart';
import '../../../features/payments/models/payment_model.dart';

class ClienteService {
  static Future<List<Agendamento>> getAgendamentosCliente(String clienteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Agendamento(
        id: '1',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Corte + Barba',
        servicoId: '1',
        barbeiroNome: 'Carlos',
        barbeiroId: '1',
        dataHora: DateTime.now().add(const Duration(days: 2)),
        status: StatusAgendamento.confirmado,
        valor: 55.0,
      ),
      Agendamento(
        id: '2',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Corte',
        servicoId: '2',
        barbeiroNome: 'Roberto',
        barbeiroId: '2',
        dataHora: DateTime.now().subtract(const Duration(days: 5)),
        status: StatusAgendamento.concluido,
        valor: 35.0,
      ),
      Agendamento(
        id: '3',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Barba',
        servicoId: '3',
        barbeiroNome: 'Carlos',
        barbeiroId: '1',
        dataHora: DateTime.now().subtract(const Duration(days: 15)),
        status: StatusAgendamento.concluido,
        valor: 25.0,
      ),
    ];
  }

  static Future<List<Payment>> getPagamentosCliente(String clienteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      Payment(
        id: '1',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Corte + Barba',
        servicoId: '1',
        barbeiroNome: 'Carlos',
        barbeiroId: '1',
        valor: 55.0,
        formaPagamento: FormaPagamento.pix,
        status: StatusPagamento.pago,
        data: DateTime.now().subtract(const Duration(days: 5)),
        chavePix: 'carlos@barbearia.com',
      ),
      Payment(
        id: '2',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Corte',
        servicoId: '2',
        barbeiroNome: 'Roberto',
        barbeiroId: '2',
        valor: 35.0,
        formaPagamento: FormaPagamento.cartao,
        status: StatusPagamento.pago,
        data: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Payment(
        id: '3',
        clienteNome: 'João Silva',
        clienteId: clienteId,
        servicoNome: 'Barba',
        servicoId: '3',
        barbeiroNome: 'Carlos',
        barbeiroId: '1',
        valor: 25.0,
        formaPagamento: FormaPagamento.dinheiro,
        status: StatusPagamento.pago,
        data: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  static Future<String> getCurrentClienteId() async {
    // Simular obtenção do ID do cliente logado via Cognito
    await Future.delayed(const Duration(milliseconds: 100));
    return 'cliente_123';
  }
}