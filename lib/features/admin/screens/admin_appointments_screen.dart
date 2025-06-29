import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Agendamentos',
      currentRoute: '/admin/appointments',
      child: _buildAppointmentsContent(),
    );
  }

  Widget _buildAppointmentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        Expanded(child: _buildAppointmentsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Agendamentos de Hoje',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TrinksTheme.darkGray,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Novo Agendamento'),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return Container(
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          _buildAppointmentItem('João Silva', '14:00', 'Corte + Barba', 'Confirmado'),
          _buildAppointmentItem('Carlos Santos', '15:30', 'Corte', 'Pendente'),
          _buildAppointmentItem('Pedro Costa', '16:00', 'Barba', 'Confirmado'),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String client, String time, String service, String status) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: TrinksTheme.lightPurple,
        child: Text(client[0], style: const TextStyle(color: TrinksTheme.navyBlue)),
      ),
      title: Text(client),
      subtitle: Text('$service - $time'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'Confirmado' ? TrinksTheme.success : TrinksTheme.warning,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: const TextStyle(color: TrinksTheme.white, fontSize: 12),
        ),
      ),
    );
  }
}