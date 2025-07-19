import 'dart:async';
import 'package:flutter/foundation.dart';

/// Uma classe para limitar a frequência de execução de uma função.
///
/// Útil para operações como busca em tempo real, onde queremos
/// evitar fazer muitas chamadas à API enquanto o usuário digita.
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}