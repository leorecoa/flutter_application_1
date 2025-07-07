import 'package:flutter/material.dart';
import '../../../core/services/services_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _servicesService = ServicesService();
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await _servicesService.getServices();
      if (response['success'] == true) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServiceDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: _services.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhum serviço cadastrado'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.build, color: Colors.white),
                            ),
                            title: Text(service['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duração: ${service['duration']} min'),
                                Text('R\$ ${service['price'].toStringAsFixed(2)}'),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Excluir'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditServiceDialog(service);
                                } else if (value == 'delete') {
                                  _deleteService(service['id']);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Serviço'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duração (min)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _servicesService.createService({
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'duration': int.tryParse(durationController.text) ?? 30,
                });
                Navigator.pop(context);
                _loadServices();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final nameController = TextEditingController(text: service['name']);
    final priceController = TextEditingController(text: service['price'].toString());
    final durationController = TextEditingController(text: service['duration'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Serviço'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço (R\$)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duração (min)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _servicesService.updateService(service['id'], {
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'duration': int.tryParse(durationController.text) ?? 30,
              });
              Navigator.pop(context);
              _loadServices();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja excluir este serviço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _servicesService.deleteService(serviceId);
      _loadServices();
    }
  }
}