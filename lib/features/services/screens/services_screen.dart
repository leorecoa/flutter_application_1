import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';
import '../../../shared/models/service_model.dart';
import '../widgets/add_service_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceModel> services = [
    ServiceModel(
      id: '1',
      name: 'Corte Masculino',
      description: 'Corte tradicional masculino',
      price: 25.0,
      duration: 30,
      category: 'Corte',
      isActive: true,
      userId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ServiceModel(
      id: '2',
      name: 'Barba Completa',
      description: 'Aparar e modelar barba',
      price: 20.0,
      duration: 20,
      category: 'Barba',
      isActive: true,
      userId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LuxuryTheme.pearl, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(service);
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return LuxuryCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(service.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getServiceIcon(service.category),
              color: _getCategoryColor(service.category),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: LuxuryTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: LuxuryTheme.primaryGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'R\$ ${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: LuxuryTheme.primaryGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${service.duration} min',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleServiceAction(value, service),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog([ServiceModel? service]) {
    showDialog(
      context: context,
      builder: (context) => AddServiceDialog(
        service: service,
        onSave: (newService) {
          setState(() {
            if (service != null) {
              final index = services.indexWhere((s) => s.id == service.id);
              if (index != -1) services[index] = newService;
            } else {
              services.add(newService);
            }
          });
        },
      ),
    );
  }

  void _handleServiceAction(String action, ServiceModel service) {
    switch (action) {
      case 'edit':
        _showAddServiceDialog(service);
        break;
      case 'delete':
        _showDeleteConfirmation(service);
        break;
    }
  }

  void _showDeleteConfirmation(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o serviço "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                services.removeWhere((s) => s.id == service.id);
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

  IconData _getServiceIcon(String category) {
    switch (category) {
      case 'Corte':
        return Icons.content_cut;
      case 'Barba':
        return Icons.face;
      case 'Combo':
        return Icons.star;
      default:
        return Icons.room_service;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Corte':
        return Colors.blue;
      case 'Barba':
        return Colors.orange;
      case 'Combo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}