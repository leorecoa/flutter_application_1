import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PixScreen extends StatefulWidget {
  const PixScreen({super.key});

  @override
  State<PixScreen> createState() => _PixScreenState();
}

class _PixScreenState extends State<PixScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isLoading = false;
  String? _pixCode;

  final List<Map<String, dynamic>> _historico = [
    {
      'id': '001',
      'valor': 150.00,
      'descricao': 'Corte de cabelo - João Silva',
      'status': 'Pago',
      'data': '2024-01-15 14:30',
    },
    {
      'id': '002',
      'valor': 80.00,
      'descricao': 'Manicure - Maria Santos',
      'status': 'Pendente',
      'data': '2024-01-15 16:00',
    },
    {
      'id': '003',
      'valor': 200.00,
      'descricao': 'Pacote completo - Ana Lima',
      'status': 'Pago',
      'data': '2024-01-14 10:15',
    },
  ];

  Future<void> _gerarPix() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simula geração do PIX
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _pixCode = '00020126580014br.gov.bcb.pix013636c4c14e-1234-4321-abcd-123456789012520400005303986540${_valorController.text}5802BR5925AGENDA FACIL LTDA6009SAO PAULO62070503***6304ABCD';
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIX gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _copiarPix() {
    if (_pixCode != null) {
      Clipboard.setData(ClipboardData(text: _pixCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código PIX copiado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIX Pagamentos'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gerar Cobrança PIX',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor (R\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Valor obrigatório';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Descrição obrigatória';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _gerarPix,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Gerar PIX'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_pixCode != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'PIX Gerado',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _pixCode!,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _copiarPix,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar Código PIX'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'Histórico de Pagamentos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historico.length,
              itemBuilder: (context, index) {
                final item = _historico[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['status'] == 'Pago' 
                          ? Colors.green 
                          : Colors.orange,
                      child: Icon(
                        item['status'] == 'Pago' 
                            ? Icons.check 
                            : Icons.schedule,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('R\$ ${item['valor'].toStringAsFixed(2)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['descricao']),
                        Text(
                          item['data'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['status'] == 'Pago' 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          color: item['status'] == 'Pago' 
                              ? Colors.green 
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}