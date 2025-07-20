import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/appointment_model.dart';
import '../application/batch_operations_controller.dart';

/// Widget para realizar operações em lote em agendamentos
class BatchOperationsWidget extends ConsumerStatefulWidget {
  final List<Appointment> selectedAppointments;
  final VoidCallback onOperationComplete;
  final VoidCallback onCancel;
  
  const BatchOperationsWidget({
    super.key,
    required this.selectedAppointments,
    required this.onOperationComplete,
    required this.onCancel,
  });

  @override
  ConsumerState<BatchOperationsWidget> createState() => _BatchOperationsWidgetState();
}

class _BatchOperationsWidgetState extends ConsumerState<BatchOperationsWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.selectedAppointments.length;
    
    return Container(
      color: theme.primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'agendamento selecionado' : 'agendamentos selecionados'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildOperationButton(
            'Confirmar',
            Icons.check_circle,
            Colors.green,
            _confirmSelected,
          ),
          const SizedBox(width: 8),
          _buildOperationButton(
            'Cancelar',
            Icons.cancel,
            Colors.red,
            _cancelSelected,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
            tooltip: 'Fechar seleção',
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperationButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  Future<void> _confirmSelected() async {
    final controller = ref.read(batchOperationsControllerProvider.notifier);
    final result = await controller.confirmAppointments(widget.selectedAppointments);
    
    if (!mounted) return;
    
    _showResultSnackBar(
      result,
      'confirmado',
      Colors.green,
    );
    
    widget.onOperationComplete();
  }
  
  Future<void> _cancelSelected() async {
    final controller = ref.read(batchOperationsControllerProvider.notifier);
    final result = await controller.cancelAppointments(widget.selectedAppointments);
    
    if (!mounted) return;
    
    _showResultSnackBar(
      result,
      'cancelado',
      Colors.orange,
    );
    
    widget.onOperationComplete();
  }
  
  void _showResultSnackBar(
    BatchOperationResult result,
    String action,
    Color color,
  ) {
    final message = StringBuffer();
    
    if (result.successCount > 0) {
      message.write('${result.successCount} ${result.successCount == 1 ? 'agendamento' : 'agendamentos'} $action com sucesso.');
    }
    
    if (result.failureCount > 0) {
      if (message.isNotEmpty) message.write(' ');
      message.write('${result.failureCount} ${result.failureCount == 1 ? 'falha' : 'falhas'}.');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        backgroundColor: result.failureCount > 0 ? Colors.orange : color,
        duration: const Duration(seconds: 4),
        action: result.errors.isNotEmpty ? SnackBarAction(
          label: 'DETALHES',
          onPressed: () => _showErrorDetailsDialog(result.errors),
        ) : null,
      ),
    );
  }
  
  void _showErrorDetailsDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes dos erros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('• $e'),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }
}