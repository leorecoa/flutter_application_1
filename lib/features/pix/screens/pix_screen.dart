import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/api_service.dart';
import '../services/pix_service.dart';

class PixScreen extends StatefulWidget {
  const PixScreen({super.key});

  @override
  State<PixScreen> createState() => _PixScreenState();
}

class _PixScreenState extends State<PixScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _apiService = ApiService();
  final _pixService = PixService();
  bool _isLoading = false;
  String? _pixCode;
  String? _pixId;
  Map<String, dynamic>? _pixData;

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

    try {
      final response = await _pixService.generatePixCode(
        amount: double.parse(_valorController.text),
        description: _descricaoController.text,
      );

      if (response['success'] == true) {
        setState(() {
          _pixCode = response['pixCode'];
          _pixId = response['pixId'];
          _pixData = response['data'];
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PIX: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: _pixCode!,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
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
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _copiarPix,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copiar'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _checkPixStatus(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Verificar'),
                          ),
                        ],
                      ),
                      if (_pixData != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Valor: R\$ ${_pixData!['amount']?.toStringAsFixed(2)}'),
                              Text('Status: ${_pixData!['status'] ?? 'Pendente'}'),
                              Text('Criado em: ${_pixData!['createdAt'] ?? ''}'),
                            ],
                          ),
                        ),
                      ],
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
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
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

  Future<void> _checkPixStatus() async {
    if (_pixId == null) return;
    
    try {
      final response = await _pixService.checkPixStatus(_pixId!);
      if (response['success'] == true && mounted) {
        setState(() {
          _pixData = response['data'];
        });
        
        final status = response['data']['status'];
        if (status == 'PAID') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pagamento confirmado!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}