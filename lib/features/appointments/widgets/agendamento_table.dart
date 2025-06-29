import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/agendamento_model.dart';

class AgendamentoTable extends StatelessWidget {
  final List<Agendamento> agendamentos;
  final Function(Agendamento) onEdit;
  final Function(String) onCancel;
  final Function(String) onComplete;
  final bool isLoading;

  const AgendamentoTable({
    super.key,
    required this.agendamentos,
    required this.onEdit,
    required this.onCancel,
    required this.onComplete,
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

    return Container(
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          _buildTableHeader(),
          ...agendamentos.map((agendamento) => _buildTableRow(agendamento)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TrinksTheme.lightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Serviço', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Barbeiro', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Data/Hora', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text('Ações', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildTableRow(Agendamento agendamento) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TrinksTheme.lightGray)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendamento.clienteNome,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'R\$ ${agendamento.valor.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(agendamento.servicoNome)),
          Expanded(flex: 2, child: Text(agendamento.barbeiroNome)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(agendamento.dataHora)),
                Text(
                  DateFormat('HH:mm').format(agendamento.dataHora),
                  style: TextStyle(
                    fontSize: 12,
                    color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _buildStatusChip(agendamento.status)),
          Expanded(flex: 1, child: _buildActions(agendamento)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatusAgendamento status) {
    Color color;
    String text;
    
    switch (status) {
      case StatusAgendamento.confirmado:
        color = TrinksTheme.success;
        text = 'Confirmado';
        break;
      case StatusAgendamento.pendente:
        color = TrinksTheme.warning;
        text = 'Pendente';
        break;
      case StatusAgendamento.cancelado:
        color = TrinksTheme.error;
        text = 'Cancelado';
        break;
      case StatusAgendamento.concluido:
        color = TrinksTheme.lightBlue;
        text = 'Concluído';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(Agendamento agendamento) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (agendamento.status != StatusAgendamento.cancelado) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => onEdit(agendamento),
            tooltip: 'Editar',
          ),
          if (agendamento.status == StatusAgendamento.confirmado)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, size: 18),
              onPressed: () => onComplete(agendamento.id),
              tooltip: 'Concluir',
            ),
          if (agendamento.status != StatusAgendamento.concluido)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, size: 18, color: TrinksTheme.error),
              onPressed: () => onCancel(agendamento.id),
              tooltip: 'Cancelar',
            ),
        ],
      ],
    );
  }
}