import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/client_model.dart';
import '../services/clients_service.dart';

class AddEditClientDialog extends StatefulWidget {
  final Client? client;
  final VoidCallback? onClientSaved;

  const AddEditClientDialog({
    super.key,
    this.client,
    this.onClientSaved,
  });

  @override
  State<AddEditClientDialog> createState() => _AddEditClientDialogState();
}

class _AddEditClientDialogState extends State<AddEditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientsService = ClientsService();
  
  bool _isLoading = false;
  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _emailController.text = widget.client!.email ?? '';
      _addressController.text = widget.client!.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço (opcional)',
                  prefixIcon: Icon(Icons.home),
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
          onPressed: _isLoading ? null : _saveClient,
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await _clientsService.updateClient(widget.client!.id, {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
          'address': _addressController.text.isEmpty ? null : _addressController.text,
        });
      } else {
        await _clientsService.createClientModel(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onClientSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cliente atualizado!' : 'Cliente criado!'),
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
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}