import 'package:flutter/material.dart';
import '../../../core/models/service_model.dart';
import '../services/services_service.dart';
import '../widgets/add_edit_service_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _servicesService = ServicesService();
  List<Service> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _servicesService.getServices();
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar serviços: $e')),
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
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Novo Serviço',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum serviço cadastrado'),
                  Text('Toque em + para começar'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return _buildServiceCard(service);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duração: ${service.duration} minutos'),
            Text('Preço: R\$ ${service.price.toStringAsFixed(2)}'),
            if (service.description != null) Text(service.description!),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editService(service),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteService(service.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog({Service? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final durationController = TextEditingController(
      text: service?.duration.toString() ?? '60',
    );
    final priceController = TextEditingController(
      text: service?.price.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: service?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Adicionar Serviço' : 'Editar Serviço'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Serviço'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duração (minutos)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          if (service != null)
            TextButton(
              onPressed: () => _deleteService(service.id),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newService = Service(
                  id: service?.id ?? DateTime.now().toString(),
                  name: nameController.text,
                  duration: int.tryParse(durationController.text) ?? 60,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );

                if (service == null) {
                  await _servicesService.createService(newService);
                } else {
                  await _servicesService.updateService(newService);
                }

                Navigator.pop(context);
                _loadServices();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        service == null
                            ? 'Serviço criado com sucesso!'
                            : 'Serviço atualizado com sucesso!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              }
            },
            child: Text(service == null ? 'Adicionar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o serviço "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteService(service.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editService(Service service) {
    _showAddEditDialog(service: service);
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await _servicesService.deleteService(serviceId);
      _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço excluído com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir serviço: $e')));
      }
    }
  }
}
