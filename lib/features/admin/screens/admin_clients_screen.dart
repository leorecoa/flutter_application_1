import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Clientes',
      currentRoute: '/admin/clients',
      child: _buildClientsContent(),
    );
  }

  Widget _buildClientsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        Expanded(child: _buildClientsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar clientes...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Novo Cliente'),
        ),
      ],
    );
  }

  Widget _buildClientsList() {
    return Container(
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          _buildClientItem('João Silva', 'joao@email.com', '(11) 99999-9999', '15 agendamentos'),
          _buildClientItem('Carlos Santos', 'carlos@email.com', '(11) 88888-8888', '8 agendamentos'),
          _buildClientItem('Pedro Costa', 'pedro@email.com', '(11) 77777-7777', '3 agendamentos'),
        ],
      ),
    );
  }

  Widget _buildClientItem(String name, String email, String phone, String appointments) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: TrinksTheme.lightPurple,
        child: Text(name[0], style: const TextStyle(color: TrinksTheme.navyBlue)),
      ),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(email),
          Text(phone),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(appointments, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Text('Total', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}