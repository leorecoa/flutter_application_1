import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/batch_progress_controller.dart';

/// Widget para exibir o progresso de operações em lote
class BatchProgressWidget extends ConsumerWidget {
  final VoidCallback? onCancel;

  const BatchProgressWidget({super.key, this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(batchProgressProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.batch_prediction, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Processando operação em lote',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onCancel != null && progressState.isProcessing)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: onCancel,
                  tooltip: 'Cancelar operação',
                ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressState.progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            '${progressState.completed} de ${progressState.total} itens processados',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (progressState.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Erro: ${progressState.error}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
