import 'package:flutter/material.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../../appointments/models/agendamento_model.dart';

class PaymentForm extends StatefulWidget {
  final Payment? payment;
  final VoidCallback onSaved;

  const PaymentForm({
    super.key,
    this.payment,
    required this.onSaved,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _chavePixController = TextEditingController();
  
  Cliente? _clienteSelecionado;
  Servico? _servicoSelecionado;
  Barbeiro? _barbeiroSelecionado;
  FormaPagamento _formaPagamento = FormaPagamento.dinheiro;
  StatusPagamento _status = StatusPagamento.pago;
  
  List<Cliente> _clientes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.payment != null) {
      _preencherFormulario();
    }
  }

  void _loadData() {
    _clientes = PaymentService.getClientes();
    setState(() {});
  }

  void _preencherFormulario() {
    final payment = widget.payment!;
    _clienteController.text = payment.clienteNome;
    _clienteSelecionado = Cliente(
      id: payment.clienteId,
      nome: payment.clienteNome,
      telefone: '',
      email: '',
    );
    _formaPagamento = payment.formaPagamento;
    _status = payment.status;
    _observacoesController.text = payment.observacoes ?? '';
    _chavePixController.text = payment.chavePix ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Flexible(child: _buildForm()),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.payment == null ? 'Novo Pagamento' : 'Editar Pagamento',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildClienteField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildServicoField()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarbeiroField()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormaPagamentoField()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusField()),
            ],
          ),
          const SizedBox(height: 16),
          if (_formaPagamento == FormaPagamento.pix) ...[
            _buildChavePixField(),
            const SizedBox(height: 16),
          ],
          _buildObservacoesField(),
        ],
      ),
    );
  }

  Widget _buildClienteField() {
    return Autocomplete<Cliente>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return _clientes;
        return _clientes.where((cliente) =>
          cliente.nome.toLowerCase().contains(textEditingValue.text.toLowerCase())
        );
      },
      displayStringForOption: (cliente) => cliente.nome,
      onSelected: (cliente) {
        _clienteSelecionado = cliente;
        _clienteController.text = cliente.nome;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        _clienteController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Cliente',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) => value?.isEmpty == true ? 'Selecione um cliente' : null,
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }

  Widget _buildServicoField() {
    return DropdownButtonFormField<Servico>(
      value: _servicoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Serviço',
        prefixIcon: Icon(Icons.content_cut_outlined),
      ),
      items: PaymentService.getServicos().map((servico) {
        return DropdownMenuItem(
          value: servico,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(servico.nome),
              Text(
                'R\$ ${servico.preco.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (servico) => setState(() => _servicoSelecionado = servico),
      validator: (value) => value == null ? 'Selecione um serviço' : null,
    );
  }

  Widget _buildBarbeiroField() {
    return DropdownButtonFormField<Barbeiro>(
      value: _barbeiroSelecionado,
      decoration: const InputDecoration(
        labelText: 'Barbeiro',
        prefixIcon: Icon(Icons.person_pin_outlined),
      ),
      items: PaymentService.getBarbeiros().map((barbeiro) {
        return DropdownMenuItem(
          value: barbeiro,
          child: Text(barbeiro.nome),
        );
      }).toList(),
      onChanged: (barbeiro) => setState(() => _barbeiroSelecionado = barbeiro),
      validator: (value) => value == null ? 'Selecione um barbeiro' : null,
    );
  }

  Widget _buildFormaPagamentoField() {
    return DropdownButtonFormField<FormaPagamento>(
      value: _formaPagamento,
      decoration: const InputDecoration(
        labelText: 'Forma de Pagamento',
        prefixIcon: Icon(Icons.payment_outlined),
      ),
      items: const [
        DropdownMenuItem(value: FormaPagamento.dinheiro, child: Text('Dinheiro')),
        DropdownMenuItem(value: FormaPagamento.pix, child: Text('PIX')),
        DropdownMenuItem(value: FormaPagamento.cartao, child: Text('Cartão')),
      ],
      onChanged: (forma) => setState(() => _formaPagamento = forma!),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<StatusPagamento>(
      value: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.check_circle_outline),
      ),
      items: const [
        DropdownMenuItem(value: StatusPagamento.pago, child: Text('Pago')),
        DropdownMenuItem(value: StatusPagamento.pendente, child: Text('Pendente')),
      ],
      onChanged: (status) => setState(() => _status = status!),
    );
  }

  Widget _buildChavePixField() {
    return TextFormField(
      controller: _chavePixController,
      decoration: const InputDecoration(
        labelText: 'Chave PIX (opcional)',
        prefixIcon: Icon(Icons.pix_outlined),
        hintText: 'email@exemplo.com ou telefone',
      ),
    );
  }

  Widget _buildObservacoesField() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        prefixIcon: Icon(Icons.notes_outlined),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvarPagamento,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.payment == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }

  void _salvarPagamento() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteSelecionado == null) return;

    setState(() => _isLoading = true);

    final payment = Payment(
      id: widget.payment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clienteNome: _clienteSelecionado!.nome,
      clienteId: _clienteSelecionado!.id,
      servicoNome: _servicoSelecionado!.nome,
      servicoId: _servicoSelecionado!.id,
      barbeiroNome: _barbeiroSelecionado!.nome,
      barbeiroId: _barbeiroSelecionado!.id,
      valor: _servicoSelecionado!.preco,
      formaPagamento: _formaPagamento,
      status: _status,
      data: DateTime.now(),
      observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
      chavePix: _formaPagamento == FormaPagamento.pix && _chavePixController.text.isNotEmpty 
          ? _chavePixController.text 
          : null,
    );

    try {
      if (widget.payment == null) {
        await PaymentService.criarPagamento(payment);
      } else {
        await PaymentService.atualizarPagamento(payment);
      }
      
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}