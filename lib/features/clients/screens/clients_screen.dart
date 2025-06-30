import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';
import '../widgets/add_client_dialog.dart';


class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  
  List<ClientModel> clients = [
    ClientModel(
      id: '1',
      name: 'Maria Silva',
      email: 'maria@email.com',
      phone: '(11) 99999-9999',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    ClientModel(
      id: '2',
      name: 'João Santos',
      email: 'joao@email.com',
      phone: '(11) 88888-8888',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddClientDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LuxuryTheme.pearl, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar clientes...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return _buildClientCard(client);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    final color = _getClientColor(client.name);
    
    return LuxuryCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              client.name[0],
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: LuxuryTheme.deepBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: client.isActive 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        client.isActive ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          color: client.isActive ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  client.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  client.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'phone',
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Ligar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleClientAction(value, client),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog([ClientModel? client]) {
    showDialog(
      context: context,
      builder: (context) => AddClientDialog(
        client: client,
        onSave: (newClient) {
          setState(() {
            if (client != null) {
              final index = clients.indexWhere((c) => c.id == client.id);
              if (index != -1) clients[index] = newClient;
            } else {
              clients.add(newClient);
            }
          });
        },
      ),
    );
  }

  void _handleClientAction(String action, ClientModel client) {
    switch (action) {
      case 'edit':
        _showAddClientDialog(client);
        break;
      case 'phone':
        // Implementar ligação
        break;
      case 'delete':
        _showDeleteConfirmation(client);
        break;
    }
  }

  void _showDeleteConfirmation(ClientModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o cliente "${client.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                clients.removeWhere((c) => c.id == client.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getClientColor(String name) {
    final colors = [Colors.blue, Colors.pink, Colors.green, Colors.orange, Colors.purple];
    return colors[name.hashCode % colors.length];
  }
}