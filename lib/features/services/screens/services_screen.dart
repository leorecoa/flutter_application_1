import 'package:flutter/material.dart';
import '../../../core/models/service_model.dart';
import '../../../core/services/services_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _servicesService = ServicesService();
  List<Service> _services = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Cabelo', 'Estética', 'Manicure', 'Massagem', 'Outros'];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await _servicesService.getServices();
      if (response['success'] == true && mounted) {
        final servicesData = List<Map<String, dynamic>>.from(response['data'] ?? []);
        final services = servicesData.map((data) => Service.fromJson(data)).toList();
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Service> get _filteredServices {
    if (_selectedCategory == 'Todos') return _services;
    return _services.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showServiceDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadServices,
                    child: _filteredServices.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.build, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Nenhum serviço encontrado'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _buildServiceCard(service);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: service.isActive ? Colors.green : Colors.grey,
          child: const Icon(Icons.build, color: Colors.white),
        ),
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            Text('${service.durationMinutes} min • ${service.category}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'R\$ ${service.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              service.isActive ? 'Ativo' : 'Inativo',
              style: TextStyle(
                color: service.isActive ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _showServiceDialog(service: service),
      ),
    );
  }

  void _showServiceDialog({Service? service}) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final descriptionController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(text: service?.price.toString() ?? '');
    final durationController = TextEditingController(text: service?.durationMinutes.toString() ?? '60');
    String selectedCategory = service?.category ?? 'Cabelo';
    bool isActive = service?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço'),
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
                  decoration: const InputDecoration(labelText: 'Duração (minutos)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: _categories.skip(1).map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Serviço Ativo'),
                  value: isActive,
                  onChanged: (value) => setDialogState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            if (isEditing)
              TextButton(
                onPressed: () => _deleteService(service.id),
                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _saveService(
                isEditing: isEditing,
                serviceId: service?.id,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0,
                duration: int.tryParse(durationController.text) ?? 60,
                category: selectedCategory,
                isActive: isActive,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveService({
    required bool isEditing,
    String? serviceId,
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
    required bool isActive,
  }) async {
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final serviceData = {
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': duration,
      'category': category,
      'isActive': isActive,
    };

    try {
      final response = isEditing
          ? await _servicesService.updateService(serviceId!, serviceData)
          : await _servicesService.createService(serviceData);

      if (response['success'] == true) {
        Navigator.pop(context);
        _loadServices();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Serviço atualizado!' : 'Serviço criado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
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
      try {
        await _servicesService.deleteService(serviceId);
        Navigator.pop(context);
        _loadServices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço excluído!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}