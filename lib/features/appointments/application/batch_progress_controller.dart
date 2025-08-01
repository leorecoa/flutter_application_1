import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para o progresso de operações em lote
class BatchProgressState {
  final int completed;
  final int total;
  final bool isProcessing;
  final String? error;

  BatchProgressState({
    required this.completed,
    required this.total,
    this.isProcessing = false,
    this.error,
  });

  /// Estado inicial
  factory BatchProgressState.initial() {
    return BatchProgressState(completed: 0, total: 0);
  }

  /// Cria uma cópia com valores atualizados
  BatchProgressState copyWith({
    int? completed,
    int? total,
    bool? isProcessing,
    String? error,
  }) {
    return BatchProgressState(
      completed: completed ?? this.completed,
      total: total ?? this.total,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }

  /// Calcula o progresso percentual
  double get progressPercentage {
    if (total == 0) return 0.0;
    return completed / total;
  }
}

/// Controller para gerenciar o progresso de operações em lote
class BatchOperationProgress extends StateNotifier<BatchProgressState> {
  BatchOperationProgress() : super(BatchProgressState.initial());

  /// Inicia uma nova operação em lote
  void startOperation(int totalItems) {
    state = BatchProgressState(
      completed: 0,
      total: totalItems,
      isProcessing: true,
    );
  }

  /// Atualiza o progresso da operação
  void updateProgress(int completed) {
    state = state.copyWith(
      completed: completed,
      isProcessing: completed < state.total,
    );
  }

  /// Incrementa o contador de itens processados
  void incrementProgress() {
    updateProgress(state.completed + 1);
  }

  /// Marca a operação como concluída
  void completeOperation() {
    state = state.copyWith(completed: state.total, isProcessing: false);
  }

  /// Marca a operação como falha
  void failOperation(String errorMessage) {
    state = state.copyWith(isProcessing: false, error: errorMessage);
  }

  /// Reseta o estado
  void reset() {
    state = BatchProgressState.initial();
  }
}

/// Provider para o progresso de operações em lote
final batchProgressProvider =
    StateNotifierProvider<BatchOperationProgress, BatchProgressState>((ref) {
      return BatchOperationProgress();
    });
