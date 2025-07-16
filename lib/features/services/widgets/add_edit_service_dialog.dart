import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/service_model.dart';
import '../services/services_service.dart';

class AddEditServiceDialog extends StatefulWidget {
  final Service? service;
  final VoidCallback? onServiceSaved;

  const AddEditServiceDialog({
    super.key,
    this.service,
    this.onServiceSaved,
  });

  @override
  State<AddEditServiceDialog> createState() => _AddEditServiceDialogState();
}

class _AddEditServiceDialogState extends State<AddEditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servicesService = ServicesService();
  
  bool _isLoading = false;
  bool get isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.service!.name;
      _durationController.text = widget.service!.duration.toString();
      _priceController.text = widget.service!.price.toString();
      _descriptionController.text = widget.service!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Serviço',
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duração (minutos)',
                  prefixIcon: Icon(Icons.schedule),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveService,
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await _servicesService.updateService(widget.service!.id, {
          'name': _nameController.text,
          'duration': int.parse(_durationController.text),
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        });
      } else {
        await _servicesService.createServiceModel(
          name: _nameController.text,
          duration: int.parse(_durationController.text),
          price: double.parse(_priceController.text),
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onServiceSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Serviço atualizado!' : 'Serviço criado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}