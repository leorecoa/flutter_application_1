import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../application/appointment_providers.dart';
import '../utils/appointment_status_utils.dart';

/// Widget para exibir estatísticas de agendamentos
class AppointmentStatisticsWidget extends ConsumerWidget {
  const AppointmentStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);
    
    return appointmentsAsync.when(
      data: (appointments) => _buildStatistics(context, appointments),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Erro ao carregar estatísticas: $error'),
      ),
    );
  }
  
  Widget _buildStatistics(BuildContext context, List<Appointment> appointments) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Calcular estatísticas
    final stats = _calculateStatistics(appointments);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas do Mês',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Total',
                  stats.total.toString(),
                  Icons.calendar_month,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Confirmados',
                  stats.confirmed.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Cancelados',
                  stats.cancelled.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Receita',
                  currencyFormat.format(stats.revenue),
                  Icons.attach_money,
                  Colors.amber,
                ),
                _buildStatCard(
                  context,
                  'Média',
                  currencyFormat.format(stats.averagePrice),
                  Icons.trending_up,
                  Colors.purple,
                ),
                _buildStatCard(
                  context,
                  'Taxa de Confirmação',
                  '${stats.confirmationRate.toStringAsFixed(0)}%',
                  Icons.verified,
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  _AppointmentStatistics _calculateStatistics(List<Appointment> appointments) {
    // Filtrar apenas agendamentos do mês atual
    final now = DateTime.now();
    final currentMonthAppointments = appointments.where((appointment) => 
      appointment.dateTime.month == now.month && 
      appointment.dateTime.year == now.year
    ).toList();
    
    // Calcular estatísticas básicas
    final total = currentMonthAppointments.length;
    final confirmed = currentMonthAppointments
        .where((a) => a.status == AppointmentStatus.confirmed || 
                      a.status == AppointmentStatus.completed)
        .length;
    final cancelled = currentMonthAppointments
        .where((a) => a.status == AppointmentStatus.cancelled)
        .length;
    
    // Calcular receita
    final revenue = currentMonthAppointments
        .where((a) => a.status != AppointmentStatus.cancelled)
        .fold(0.0, (sum, a) => sum + a.price);
    
    // Calcular média de preço
    final averagePrice = total > 0 ? revenue / total : 0.0;
    
    // Calcular taxa de confirmação
    final scheduledOrConfirmed = currentMonthAppointments
        .where((a) => a.status == AppointmentStatus.scheduled || 
                      a.status == AppointmentStatus.confirmed ||
                      a.status == AppointmentStatus.completed)
        .length;
    final confirmationRate = scheduledOrConfirmed > 0 
        ? (confirmed / scheduledOrConfirmed) * 100 
        : 0.0;
    
    return _AppointmentStatistics(
      total: total,
      confirmed: confirmed,
      cancelled: cancelled,
      revenue: revenue,
      averagePrice: averagePrice,
      confirmationRate: confirmationRate,
    );
  }
}

/// Classe para armazenar estatísticas de agendamentos
class _AppointmentStatistics {
  final int total;
  final int confirmed;
  final int cancelled;
  final double revenue;
  final double averagePrice;
  final double confirmationRate;
  
  _AppointmentStatistics({
    required this.total,
    required this.confirmed,
    required this.cancelled,
    required this.revenue,
    required this.averagePrice,
    required this.confirmationRate,
  });
}