import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../../appointments/models/agendamento_model.dart';

class ListaAgendamentos extends StatelessWidget {
  final List<Agendamento> agendamentos;
  final bool isLoading;

  const ListaAgendamentos({
    super.key,
    required this.agendamentos,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (agendamentos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agendamentos.length,
      itemBuilder: (context, index) {
        final agendamento = agendamentos[index];
        return _buildAgendamentoCard(agendamento);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: TrinksTheme.darkGray.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum agendamento encontrado',
            style: TextStyle(
              fontSize: 18,
              color: TrinksTheme.darkGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    final isFuturo = agendamento.dataHora.isAfter(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TrinksTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(agendamento.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: _getStatusColor(agendamento.status),
              size: 24,
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
                      '📅 ${DateFormat('dd/MM/yyyy').format(agendamento.dataHora)} – ${DateFormat('HH:mm').format(agendamento.dataHora)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${agendamento.servicoNome} com ${agendamento.barbeiroNome}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: TrinksTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(agendamento.status, isFuturo),
                    const Spacer(),
                    Text(
                      'R\$ ${agendamento.valor.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: TrinksTheme.navyBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatusAgendamento status, bool isFuturo) {
    String emoji;
    String text;
    Color color;

    if (isFuturo) {
      emoji = '🕒';
      text = 'Agendado';
      color = TrinksTheme.lightBlue;
    } else {
      switch (status) {
        case StatusAgendamento.concluido:
          emoji = '✅';
          text = 'Concluído';
          color = TrinksTheme.success;
          break;
        case StatusAgendamento.cancelado:
          emoji = '❌';
          text = 'Cancelado';
          color = TrinksTheme.error;
          break;
        default:
          emoji = '⏳';
          text = 'Pendente';
          color = TrinksTheme.warning;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StatusAgendamento status) {
    switch (status) {
      case StatusAgendamento.concluido:
        return TrinksTheme.success;
      case StatusAgendamento.cancelado:
        return TrinksTheme.error;
      case StatusAgendamento.confirmado:
        return TrinksTheme.lightBlue;
      default:
        return TrinksTheme.warning;
    }
  }
}