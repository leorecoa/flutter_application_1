import 'package:flutter/material.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Configurações',
      currentRoute: '/admin/settings',
      child: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection('Perfil da Barbearia', [
            _buildSettingItem('Nome da Barbearia', 'Barbearia do João', Icons.store),
            _buildSettingItem('Endereço', 'Rua das Flores, 123', Icons.location_on),
            _buildSettingItem('Telefone', '(11) 99999-9999', Icons.phone),
            _buildSettingItem('Email', 'contato@barbearia.com', Icons.email),
          ]),
          const SizedBox(height: 32),
          _buildSettingsSection('Horário de Funcionamento', [
            _buildSettingItem('Segunda a Sexta', '08:00 - 18:00', Icons.schedule),
            _buildSettingItem('Sábado', '08:00 - 16:00', Icons.schedule),
            _buildSettingItem('Domingo', 'Fechado', Icons.schedule_outlined),
          ]),
          const SizedBox(height: 32),
          _buildSettingsSection('Notificações', [
            _buildSwitchItem('Novos agendamentos', true),
            _buildSwitchItem('Lembretes de pagamento', true),
            _buildSwitchItem('Relatórios semanais', false),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: TrinksTheme.darkGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: TrinksTheme.darkGray,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: TrinksTheme.darkGray,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {},
            activeColor: TrinksTheme.navyBlue,
          ),
        ],
      ),
    );
  }
}