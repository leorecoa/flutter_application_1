import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/logger.dart';

/// Provider para o serviço de armazenamento
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageServiceImpl();
});

/// Interface para o serviço de armazenamento
abstract class StorageService {
  /// Inicializa o serviço de armazenamento
  Future<void> initialize();

  /// Obtém um valor do armazenamento
  Future<dynamic> getValue(String key);

  /// Define um valor no armazenamento
  Future<void> setValue(String key, dynamic value);

  /// Remove um valor do armazenamento
  Future<void> removeValue(String key);

  /// Limpa todos os valores do armazenamento
  Future<void> clear();

  /// Salva um arquivo na pasta de downloads
  Future<String> saveToDownloads(String fileName, String content);

  /// Salva um arquivo na pasta temporária
  Future<String> saveToTemp(String fileName, String content);

  /// Lê um arquivo
  Future<String> readFile(String filePath);

  /// Verifica se um arquivo existe
  Future<bool> fileExists(String filePath);

  /// Exclui um arquivo
  Future<void> deleteFile(String filePath);
}

/// Implementação do serviço de armazenamento
class StorageServiceImpl implements StorageService {
  late SharedPreferences _prefs;

  @override
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      Logger.info('Serviço de armazenamento inicializado');
    } catch (e) {
      Logger.error('Erro ao inicializar serviço de armazenamento', error: e);
      throw ServiceException(
        'Erro ao inicializar serviço de armazenamento: $e',
      );
    }
  }

  @override
  Future<dynamic> getValue(String key) async {
    try {
      if (!_prefs.containsKey(key)) {
        return null;
      }

      if (_prefs.getString(key) != null) {
        return _prefs.getString(key);
      } else if (_prefs.getBool(key) != null) {
        return _prefs.getBool(key);
      } else if (_prefs.getInt(key) != null) {
        return _prefs.getInt(key);
      } else if (_prefs.getDouble(key) != null) {
        return _prefs.getDouble(key);
      } else if (_prefs.getStringList(key) != null) {
        return _prefs.getStringList(key);
      }

      return null;
    } catch (e) {
      Logger.error(
        'Erro ao obter valor do armazenamento',
        error: e,
        context: {'key': key},
      );
      throw ServiceException('Erro ao obter valor do armazenamento: $e');
    }
  }

  @override
  Future<void> setValue(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else if (value is Map) {
        await _prefs.setString(key, value.toString());
      } else {
        throw ServiceException(
          'Tipo de valor não suportado: ${value.runtimeType}',
        );
      }

      Logger.info(
        'Valor definido no armazenamento',
        context: {'key': key, 'valueType': value.runtimeType.toString()},
      );
    } catch (e) {
      Logger.error(
        'Erro ao definir valor no armazenamento',
        error: e,
        context: {'key': key, 'valueType': value?.runtimeType.toString()},
      );
      throw ServiceException('Erro ao definir valor no armazenamento: $e');
    }
  }

  @override
  Future<void> removeValue(String key) async {
    try {
      await _prefs.remove(key);
      Logger.info('Valor removido do armazenamento', context: {'key': key});
    } catch (e) {
      Logger.error(
        'Erro ao remover valor do armazenamento',
        error: e,
        context: {'key': key},
      );
      throw ServiceException('Erro ao remover valor do armazenamento: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
      Logger.info('Armazenamento limpo');
    } catch (e) {
      Logger.error('Erro ao limpar armazenamento', error: e);
      throw ServiceException('Erro ao limpar armazenamento: $e');
    }
  }

  @override
  Future<String> saveToDownloads(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/downloads');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(content);

      Logger.info(
        'Arquivo salvo na pasta de downloads',
        context: {
          'fileName': fileName,
          'filePath': file.path,
          'fileSize': content.length,
        },
      );

      return file.path;
    } catch (e) {
      Logger.error(
        'Erro ao salvar arquivo na pasta de downloads',
        error: e,
        context: {'fileName': fileName},
      );
      throw ServiceException(
        'Erro ao salvar arquivo na pasta de downloads: $e',
      );
    }
  }

  @override
  Future<String> saveToTemp(String fileName, String content) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      Logger.info(
        'Arquivo salvo na pasta temporária',
        context: {
          'fileName': fileName,
          'filePath': file.path,
          'fileSize': content.length,
        },
      );

      return file.path;
    } catch (e) {
      Logger.error(
        'Erro ao salvar arquivo na pasta temporária',
        error: e,
        context: {'fileName': fileName},
      );
      throw ServiceException('Erro ao salvar arquivo na pasta temporária: $e');
    }
  }

  @override
  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw NotFoundException('Arquivo não encontrado: $filePath');
      }

      final content = await file.readAsString();

      Logger.info(
        'Arquivo lido',
        context: {'filePath': filePath, 'fileSize': content.length},
      );

      return content;
    } catch (e) {
      Logger.error(
        'Erro ao ler arquivo',
        error: e,
        context: {'filePath': filePath},
      );
      if (e is NotFoundException) rethrow;
      throw ServiceException('Erro ao ler arquivo: $e');
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      Logger.error(
        'Erro ao verificar existência de arquivo',
        error: e,
        context: {'filePath': filePath},
      );
      throw ServiceException('Erro ao verificar existência de arquivo: $e');
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw NotFoundException('Arquivo não encontrado: $filePath');
      }

      await file.delete();

      Logger.info('Arquivo excluído', context: {'filePath': filePath});
    } catch (e) {
      Logger.error(
        'Erro ao excluir arquivo',
        error: e,
        context: {'filePath': filePath},
      );
      if (e is NotFoundException) rethrow;
      throw ServiceException('Erro ao excluir arquivo: $e');
    }
  }
}
