import 'package:flutter/material.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class SimplePaymentForm extends StatefulWidget {
  final Payment? payment;
  final VoidCallback onSaved;

  const SimplePaymentForm({
    super.key,
    this.payment,
    required this.onSaved,
  });

  @override
  State<SimplePaymentForm> createState() => _SimplePaymentFormState();
}

class _SimplePaymentFormState extends State<SimplePaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _servicoController = TextEditingController();
  final _valorController = TextEditingController();
  final _chavePixController = TextEditingController();
  
  FormaPagamento _formaPagamento = FormaPagamento.pix;
  StatusPagamento _status = StatusPagamento.pendente;
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _loadData();
    }
  }

  void _loadData() {
    final payment = widget.payment!;
    _clienteController.text = payment.clienteNome;
    _servicoController.text = payment.servicoNome;
    _valorController.text = payment.valor.toString();
    _chavePixController.text = payment.chavePix ?? '';
    _formaPagamento = payment.formaPagamento;
    _status = payment.status;
    _data = payment.data;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.payment == null ? 'Novo Pagamento' : 'Editar Pagamento',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clienteController,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _servicoController,
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<FormaPagamento>(
                      value: _formaPagamento,
                      decoration: const InputDecoration(
                        labelText: 'Forma de Pagamento',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: FormaPagamento.pix, child: Text('PIX')),
                        DropdownMenuItem(value: FormaPagamento.cartao, child: Text('Cartão')),
                        DropdownMenuItem(value: FormaPagamento.dinheiro, child: Text('Dinheiro')),
                      ],
                      onChanged: (value) => setState(() => _formaPagamento = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_formaPagamento == FormaPagamento.pix) ...[
                TextFormField(
                  controller: _chavePixController,
                  decoration: const InputDecoration(
                    labelText: 'Chave PIX',
                    border: OutlineInputBorder(),
                    hintText: 'Email, telefone ou chave aleatória',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<StatusPagamento>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: StatusPagamento.pendente, child: Text('Pendente')),
                  DropdownMenuItem(value: StatusPagamento.pago, child: Text('Pago')),
                  DropdownMenuItem(value: StatusPagamento.cancelado, child: Text('Cancelado')),
                ],
                onChanged: (value) => setState(() => _status = value!),
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
                    onPressed: _save,
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

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: widget.payment?.id ?? '',
        clienteId: 'cliente-${DateTime.now().millisecondsSinceEpoch}',
        clienteNome: _clienteController.text,
        servicoId: 'servico-${DateTime.now().millisecondsSinceEpoch}',
        servicoNome: _servicoController.text,
        barbeiroId: 'barbeiro-1',
        barbeiroNome: 'Profissional',
        valor: double.parse(_valorController.text),
        formaPagamento: _formaPagamento,
        data: _data,
        status: _status,
        chavePix: _formaPagamento == FormaPagamento.pix ? _chavePixController.text : null,
      );

      if (widget.payment == null) {
        await PaymentService.criarPagamento(payment);
      } else {
        await PaymentService.atualizarPagamento(payment);
      }

      widget.onSaved();
      Navigator.pop(context);
    }
  }
}