import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../appointments/services/agendamento_service.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../widgets/pagamentos_table.dart';
import '../widgets/simple_payment_form.dart';
import '../widgets/recibo_modal.dart';

class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  final _buscaController = TextEditingController();
  List<Payment> _payments = [];
  RelatorioFinanceiro? _relatorio;
  bool _isLoading = false;

  String? _filtroBarbeiro;
  FormaPagamento? _filtroFormaPagamento;
  StatusPagamento? _filtroStatus;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _buscaController.addListener(_onBuscaChanged);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _onBuscaChanged() {
    _carregarPayments();
  }

  Future<void> _carregarDados() async {
    await Future.wait([
      _carregarPayments(),
      _carregarRelatorio(),
    ]);
  }

  Future<void> _carregarPayments() async {
    setState(() => _isLoading = true);

    final payments = await PaymentService.getPayments(
      filtroCliente: _buscaController.text,
      filtroFormaPagamento: _filtroFormaPagamento,
      filtroStatus: _filtroStatus,
      dataInicio: _filtroDataInicio,
      dataFim: _filtroDataFim,
    );

    setState(() {
      _payments = payments;
      _isLoading = false;
    });
  }

  Future<void> _carregarRelatorio() async {
    final resumo = await PaymentService.getResumoFinanceiro();

    setState(() => _relatorio = RelatorioFinanceiro(
          totalRecebido: resumo['receitaMes'] ?? 0.0,
          totalPendente: resumo['pendentes'] ?? 0.0,
          totalTransacoes: _payments.length,
          receitaPorBarbeiro: {},
          receitaPorFormaPagamento: {
            FormaPagamento.pix: (resumo['receitaMes'] ?? 0.0) * 0.6,
            FormaPagamento.dinheiro: (resumo['receitaMes'] ?? 0.0) * 0.3,
            FormaPagamento.cartao: (resumo['receitaMes'] ?? 0.0) * 0.1,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Financeiro',
      currentRoute: '/admin/financial',
      floatingActionButton: FloatingActionButton(
        onPressed: _novoPayment,
        backgroundColor: TrinksTheme.navyBlue,
        child: const Icon(Icons.add, color: TrinksTheme.white),
      ),
      child: Column(
        children: [
          if (_relatorio != null) ...[
            _buildResumoFinanceiro(),
            const SizedBox(height: 24),
          ],
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: PagamentosTable(
              payments: _payments,
              isLoading: _isLoading,
              onEdit: _editarPayment,
              onCancel: _cancelarPayment,
              onEmitirRecibo: _emitirRecibo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoFinanceiro() {
    final relatorio = _relatorio!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        DashboardCard(
          title: 'Total Recebido',
          value: 'R\$ ${relatorio.totalRecebido.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          iconColor: TrinksTheme.success,
          subtitle: '${relatorio.totalTransacoes} transações',
        ),
        DashboardCard(
          title: 'Pendente',
          value: 'R\$ ${relatorio.totalPendente.toStringAsFixed(0)}',
          icon: Icons.schedule,
          iconColor: TrinksTheme.warning,
          subtitle: 'A receber',
        ),
        DashboardCard(
          title: 'PIX',
          value:
              'R\$ ${(relatorio.receitaPorFormaPagamento[FormaPagamento.pix] ?? 0).toStringAsFixed(0)}',
          icon: Icons.pix,
          iconColor: TrinksTheme.lightBlue,
          subtitle: 'Pagamentos PIX',
        ),
        DashboardCard(
          title: 'Dinheiro',
          value:
              'R\$ ${(relatorio.receitaPorFormaPagamento[FormaPagamento.dinheiro] ?? 0).toStringAsFixed(0)}',
          icon: Icons.attach_money,
          iconColor: TrinksTheme.success,
          subtitle: 'Pagamentos em dinheiro',
        ),
      ],
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
              Expanded(child: _buildDataInicioFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildDataFimFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarbeiroFilter()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormaPagamentoFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusFilter()),
              const SizedBox(width: 16),
              Expanded(child: Container()),
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

  Widget _buildDataInicioFilter() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Data início',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: _filtroDataInicio != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _filtroDataInicio = null);
                  _carregarDados();
                },
              )
            : null,
      ),
      controller: TextEditingController(
        text: _filtroDataInicio != null
            ? DateFormat('dd/MM/yyyy').format(_filtroDataInicio!)
            : '',
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _filtroDataInicio ??
              DateTime.now().subtract(const Duration(days: 30)),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (data != null) {
          setState(() => _filtroDataInicio = data);
          _carregarDados();
        }
      },
    );
  }

  Widget _buildDataFimFilter() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Data fim',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: _filtroDataFim != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _filtroDataFim = null);
                  _carregarDados();
                },
              )
            : null,
      ),
      controller: TextEditingController(
        text: _filtroDataFim != null
            ? DateFormat('dd/MM/yyyy').format(_filtroDataFim!)
            : '',
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _filtroDataFim ?? DateTime.now(),
          firstDate: _filtroDataInicio ??
              DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (data != null) {
          setState(() => _filtroDataFim = data);
          _carregarDados();
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
        const DropdownMenuItem(child: Text('Todos os barbeiros')),
        ...AgendamentoService.getBarbeiros().map((barbeiro) {
          return DropdownMenuItem(
            value: barbeiro.id,
            child: Text(barbeiro.nome),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _filtroBarbeiro = value);
        _carregarDados();
      },
    );
  }

  Widget _buildFormaPagamentoFilter() {
    return DropdownButtonFormField<FormaPagamento>(
      value: _filtroFormaPagamento,
      decoration: const InputDecoration(
        hintText: 'Forma de pagamento',
        prefixIcon: Icon(Icons.payment_outlined),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(child: Text('Todas as formas')),
        DropdownMenuItem(value: FormaPagamento.pix, child: Text('PIX')),
        DropdownMenuItem(
            value: FormaPagamento.dinheiro, child: Text('Dinheiro')),
        DropdownMenuItem(value: FormaPagamento.cartao, child: Text('Cartão')),
      ],
      onChanged: (value) {
        setState(() => _filtroFormaPagamento = value);
        _carregarDados();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<StatusPagamento>(
      value: _filtroStatus,
      decoration: const InputDecoration(
        hintText: 'Status',
        prefixIcon: Icon(Icons.filter_list_outlined),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(child: Text('Todos os status')),
        DropdownMenuItem(value: StatusPagamento.pago, child: Text('Pago')),
        DropdownMenuItem(
            value: StatusPagamento.pendente, child: Text('Pendente')),
        DropdownMenuItem(
            value: StatusPagamento.cancelado, child: Text('Cancelado')),
      ],
      onChanged: (value) {
        setState(() => _filtroStatus = value);
        _carregarDados();
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
      _filtroFormaPagamento = null;
      _filtroStatus = null;
      _filtroDataInicio = null;
      _filtroDataFim = null;
    });
    _carregarDados();
  }

  void _novoPayment() {
    showDialog(
      context: context,
      builder: (context) => SimplePaymentForm(
        onSaved: _carregarDados,
      ),
    );
  }

  void _editarPayment(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => SimplePaymentForm(
        payment: payment,
        onSaved: _carregarDados,
      ),
    );
  }

  void _cancelarPayment(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pagamento'),
        content: const Text('Tem certeza que deseja cancelar este pagamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await PaymentService.cancelarPagamento(id);
              _carregarDados();
            },
            style: ElevatedButton.styleFrom(backgroundColor: TrinksTheme.error),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _emitirRecibo(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => ReciboModal(payment: payment),
    );
  }
}
