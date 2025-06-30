import 'package:flutter/material.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';

class PaymentFormDialog extends StatefulWidget {
  final Payment? payment;
  final Function(Payment) onSave;

  const PaymentFormDialog({
    super.key,
    this.payment,
    required this.onSave,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _barbeiroController = TextEditingController();
  final _valorController = TextEditingController();
  final _chavePixController = TextEditingController();
  final _observacoesController = TextEditingController();

  FormaPagamento _formaPagamento = FormaPagamento.pix;
  StatusPagamento _status = StatusPagamento.pendente;
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _loadPaymentData();
    }
  }

  void _loadPaymentData() {
    final payment = widget.payment!;
    _clienteController.text = payment.clienteNome;
    _servicoController.text = payment.servicoNome;
    _barbeiroController.text = payment.barbeiroNome;
    _valorController.text = payment.valor.toString();
    _chavePixController.text = payment.chavePix ?? '';
    _observacoesController.text = payment.observacoes ?? '';
    _formaPagamento = payment.formaPagamento;
    _status = payment.status;
    _data = payment.data;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.payment == null ? 'Novo Pagamento' : 'Editar Pagamento',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TrinksTheme.darkGray,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildClienteField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildServicoField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildBarbeiroField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildValorField()),
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
                      if (_formaPagamento == FormaPagamento.pix)
                        _buildChavePixField(),
                      const SizedBox(height: 16),
                      _buildObservacoesField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _savePayment,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClienteField() {
    return TextFormField(
      controller: _clienteController,
      decoration: const InputDecoration(
        labelText: 'Cliente',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildServicoField() {
    return TextFormField(
      controller: _servicoController,
      decoration: const InputDecoration(
        labelText: 'Serviço',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildBarbeiroField() {
    return TextFormField(
      controller: _barbeiroController,
      decoration: const InputDecoration(
        labelText: 'Profissional',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildValorField() {
    return TextFormField(
      controller: _valorController,
      decoration: const InputDecoration(
        labelText: 'Valor (R\$)',
        border: OutlineInputBorder(),
        prefixText: 'R\$ ',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty == true) return 'Campo obrigatório';
        if (double.tryParse(value!) == null) return 'Valor inválido';
        return null;
      },
    );
  }

  Widget _buildFormaPagamentoField() {
    return DropdownButtonFormField<FormaPagamento>(
      value: _formaPagamento,
      decoration: const InputDecoration(
        labelText: 'Forma de Pagamento',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: FormaPagamento.pix, child: Text('PIX')),
        DropdownMenuItem(value: FormaPagamento.cartao, child: Text('Cartão')),
        DropdownMenuItem(
            value: FormaPagamento.dinheiro, child: Text('Dinheiro')),
      ],
      onChanged: (value) => setState(() => _formaPagamento = value!),
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<StatusPagamento>(
      value: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
            value: StatusPagamento.pendente, child: Text('Pendente')),
        DropdownMenuItem(
            value: StatusPagamento.pago, child: Text('Pago')),
        DropdownMenuItem(
            value: StatusPagamento.cancelado, child: Text('Cancelado')),
      ],
      onChanged: (value) => setState(() => _status = value!),
    );
  }

  Widget _buildChavePixField() {
    return TextFormField(
      controller: _chavePixController,
      decoration: const InputDecoration(
        labelText: 'Chave PIX',
        border: OutlineInputBorder(),
        hintText: 'Email, telefone ou chave aleatória',
      ),
    );
  }

  Widget _buildObservacoesField() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: widget.payment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        clienteNome: _clienteController.text,
        clienteId: widget.payment?.clienteId ?? 'cliente-${DateTime.now().millisecondsSinceEpoch}',
        servicoNome: _servicoController.text,
        servicoId: widget.payment?.servicoId ?? 'servico-${DateTime.now().millisecondsSinceEpoch}',
        barbeiroNome: _barbeiroController.text,
        barbeiroId: widget.payment?.barbeiroId ?? 'barbeiro-${DateTime.now().millisecondsSinceEpoch}',
        valor: double.parse(_valorController.text),
        formaPagamento: _formaPagamento,
        data: _data,
        status: _status,
        chavePix: _formaPagamento == FormaPagamento.pix
            ? _chavePixController.text
            : null,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
      );

      widget.onSave(payment);
      Navigator.pop(context);
    }
  }
}
