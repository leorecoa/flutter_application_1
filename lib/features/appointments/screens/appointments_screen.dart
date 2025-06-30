import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../services/agendamento_service.dart';
import '../models/agendamento_model.dart';
import '../widgets/add_appointment_dialog.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // List<Agendamento> _agendamentos = []; // Unused field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    try {
      final agendamentos = await AgendamentoService.getAgendamentos();
      // Use agendamentos for future implementation
      debugPrint('Loaded ${agendamentos.length} agendamentos');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointment(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LuxuryTheme.pearl, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTodaySection(),
                  const SizedBox(height: 24),
                  _buildUpcomingSection(),
                ],
              ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoje - 15 Dezembro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(
          'Maria Silva',
          'Corte + Escova',
          '09:00',
          'Confirmado',
          Colors.green,
        ),
        _buildAppointmentCard(
          'João Santos',
          'Barba + Bigode',
          '10:30',
          'Confirmado',
          Colors.green,
        ),
        _buildAppointmentCard(
          'Ana Costa',
          'Manicure',
          '14:00',
          'Pendente',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos Dias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(
          'Carlos Lima',
          'Corte Masculino',
          'Amanhã - 16:00',
          'Confirmado',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String name, String service, String time, String status, Color statusColor) {
    return LuxuryCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: LuxuryTheme.primaryGold.withValues(alpha: 0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: LuxuryTheme.primaryGold,
                fontWeight: FontWeight.w600,
              ),
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
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: LuxuryTheme.primaryGold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointment() {
    showDialog(
      context: context,
      builder: (context) => AddAppointmentDialog(
        onSave: (Agendamento agendamento) async {
          setState(() => _isLoading = true);
          await AgendamentoService.criarAgendamento(agendamento);
          await _loadAgendamentos();
          setState(() => _isLoading = false);
        },
      ),
    );
  }
}