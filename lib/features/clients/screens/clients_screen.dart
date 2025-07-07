import 'package:flutter/material.dart';
import '../../../core/services/clients_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _clientsService = ClientsService();
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final response = await _clientsService.getClients();
      if (response['success'] == true) {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(response['data'] ?? []);
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
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddClientDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClients,
              child: _clients.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhum cliente cadastrado'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clients.length,
                      itemBuilder: (context, index) {
                        final client = _clients[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(client['name'][0].toUpperCase()),
                            ),
                            title: Text(client['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(client['phone'] ?? ''),
                                Text(client['email'] ?? ''),
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
                                  _showEditClientDialog(client);
                                } else if (value == 'delete') {
                                  _deleteClient(client['id']);
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

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
                await _clientsService.createClient({
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                });
                Navigator.pop(context);
                _loadClients();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditClientDialog(Map<String, dynamic> client) {
    final nameController = TextEditingController(text: client['name']);
    final phoneController = TextEditingController(text: client['phone']);
    final emailController = TextEditingController(text: client['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
              await _clientsService.updateClient(client['id'], {
                'name': nameController.text,
                'phone': phoneController.text,
                'email': emailController.text,
              });
              Navigator.pop(context);
              _loadClients();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(String clientId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja excluir este cliente?'),
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
      await _clientsService.deleteClient(clientId);
      _loadClients();
    }
  }
}