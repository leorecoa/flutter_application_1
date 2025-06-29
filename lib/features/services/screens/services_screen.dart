import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddService(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LuxuryTheme.pearl, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildServiceCard(
              'Corte Masculino',
              'Corte moderno e estiloso',
              'R\$ 35,00',
              '45 min',
              Icons.content_cut,
              Colors.blue,
            ),
            _buildServiceCard(
              'Corte + Escova',
              'Corte feminino com escova',
              'R\$ 65,00',
              '90 min',
              Icons.brush,
              Colors.pink,
            ),
            _buildServiceCard(
              'Barba + Bigode',
              'Aparar e modelar barba',
              'R\$ 25,00',
              '30 min',
              Icons.face,
              Colors.brown,
            ),
            _buildServiceCard(
              'Manicure',
              'Cuidados com as unhas',
              'R\$ 20,00',
              '60 min',
              Icons.back_hand,
              Colors.purple,
            ),
            _buildServiceCard(
              'Pedicure',
              'Cuidados com os pés',
              'R\$ 25,00',
              '60 min',
              Icons.accessibility,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String name, String description, String price, String duration, IconData icon, Color color) {
    return LuxuryCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: LuxuryTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
                        price,
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
                        duration,
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
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditService(name),
          ),
        ],
      ),
    );
  }

  void _showAddService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Serviço'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditService(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $name'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}