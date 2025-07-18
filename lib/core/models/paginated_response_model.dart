import 'package:flutter/foundation.dart';

/// Um modelo genérico para encapsular respostas paginadas da API.
///
/// [T] é o tipo dos itens na lista.
@immutable
class PaginatedResponse<T> {
  /// A lista de itens para a página atual.
  final List<T> items;

  /// A chave para buscar a próxima página de resultados.
  /// Se for nulo, significa que não há mais páginas.
  final String? lastKey;

  const PaginatedResponse({required this.items, this.lastKey});

  bool get hasMore => lastKey != null;
}