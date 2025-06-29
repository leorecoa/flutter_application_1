import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _whatsappNotifications = false;
  String _businessName = 'Minha Barbearia';
  String _businessPhone = '(11) 99999-9999';
  String _businessAddress = 'Rua das Flores, 123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: LuxuryTheme.deepBlue,
        foregroundColor: Colors.white,
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
            _buildBusinessSection(),
            const SizedBox(height: 16),
            _buildNotificationsSection(),
            const SizedBox(height: 16),
            _buildIntegrationsSection(),
            const SizedBox(height: 16),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Negócio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _businessName,
            decoration: const InputDecoration(
              labelText: 'Nome do Negócio',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _businessName = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _businessPhone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _businessPhone = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _businessAddress,
            decoration: const InputDecoration(
              labelText: 'Endereço',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => setState(() => _businessAddress = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveBusinessInfo,
            child: const Text('Salvar Informações'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Notificações Push'),
            subtitle: const Text('Receber notificações no app'),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            activeColor: LuxuryTheme.primaryGold,
          ),
          SwitchListTile(
            title: const Text('Notificações por Email'),
            subtitle: const Text('Receber emails sobre agendamentos'),
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
            activeColor: LuxuryTheme.primaryGold,
          ),
          SwitchListTile(
            title: const Text('Notificações WhatsApp'),
            subtitle: const Text('Receber mensagens no WhatsApp'),
            value: _whatsappNotifications,
            onChanged: (value) => setState(() => _whatsappNotifications = value),
            activeColor: LuxuryTheme.primaryGold,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Integrações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text('Google Calendar'),
            subtitle: const Text('Sincronizar agendamentos'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showIntegrationDialog('Google Calendar'),
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('WhatsApp Business'),
            subtitle: const Text('Configurar API do WhatsApp'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showIntegrationDialog('WhatsApp'),
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.purple),
            title: const Text('Pagamentos'),
            subtitle: const Text('Configurar Stripe/Mercado Pago'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showIntegrationDialog('Pagamentos'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Perfil'),
            subtitle: const Text('Editar informações pessoais'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showProfileDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.orange),
            title: const Text('Segurança'),
            subtitle: const Text('Alterar senha e configurações'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showSecurityDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text('Backup'),
            subtitle: const Text('Fazer backup dos dados'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showBackupDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair'),
            subtitle: const Text('Fazer logout da conta'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  void _saveBusinessInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informações salvas com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showIntegrationDialog(String integration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurar $integration'),
        content: Text('Configuração de $integration em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: const Text('Funcionalidade em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Segurança'),
        content: const Text('Funcionalidade em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup de Dados'),
        content: const Text('Funcionalidade em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar logout
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}