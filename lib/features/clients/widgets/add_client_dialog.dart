import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final DateTime? birthDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.birthDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });
}

class AddClientDialog extends StatefulWidget {
  final ClientModel? client;
  final Function(ClientModel) onSave;

  const AddClientDialog({
    super.key,
    this.client,
    required this.onSave,
  });

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _birthDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _emailController.text = widget.client!.email;
      _phoneController.text = widget.client!.phone;
      _addressController.text = widget.client!.address ?? '';
      _notesController.text = widget.client!.notes ?? '';
      _birthDate = widget.client!.birthDate;
      _isActive = widget.client!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.client == null ? 'Novo Cliente' : 'Editar Cliente',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: LuxuryTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Campo obrigatório';
                          if (!value!.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _birthDate == null 
                      ? 'Data de Nascimento (opcional)' 
                      : 'Nascimento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectBirthDate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Cliente Ativo'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: LuxuryTheme.gold,
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
                      onPressed: _saveClient,
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final client = ClientModel(
        id: widget.client?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        birthDate: _birthDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isActive: _isActive,
        createdAt: widget.client?.createdAt ?? DateTime.now(),
      );
      
      widget.onSave(client);
      Navigator.pop(context);
    }
  }
}