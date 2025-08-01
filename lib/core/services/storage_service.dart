import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

/// Serviço para gerenciar armazenamento local
class StorageService {
  /// Provider para o serviço de armazenamento
  static final provider = Provider<StorageService>((ref) {
    return StorageService();
  });
  
  /// Salva dados na pasta de downloads
  Future<String> saveToDownloads(String fileName, dynamic data) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));
    return '/downloads/$fileName';
  }
  
  /// Lê um arquivo
  Future<dynamic> readFile(String filePath, {bool asBinary = false}) async {
    // Implementação mock para desenvolvimento
    await Future.delayed(const Duration(milliseconds: 100));
    return asBinary ? Uint8List(0) : '';
  }
}