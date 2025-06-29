import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Serviços',
      currentRoute: '/admin/services',
      child: _buildServicesContent(),
    );
  }

  Widget _buildServicesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        Expanded(child: _buildServicesList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Serviços Disponíveis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Novo Serviço'),
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildServiceCard('Corte Masculino', 'R\$ 35,00', '45 min', Icons.content_cut),
        _buildServiceCard('Barba', 'R\$ 25,00', '30 min', Icons.face),
        _buildServiceCard('Corte + Barba', 'R\$ 55,00', '60 min', Icons.person),
        _buildServiceCard('Sobrancelha', 'R\$ 15,00', '15 min', Icons.visibility),
        _buildServiceCard('Lavagem', 'R\$ 10,00', '20 min', Icons.local_car_wash),
        _buildServiceCard('Tratamento', 'R\$ 45,00', '40 min', Icons.spa),
      ],
    );
  }

  Widget _buildServiceCard(String name, String price, String duration, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TrinksTheme.lightPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TrinksTheme.navyBlue, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TrinksTheme.navyBlue,
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              color: TrinksTheme.darkGray.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}