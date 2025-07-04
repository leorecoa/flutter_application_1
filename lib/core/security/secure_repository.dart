import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'audit_logger.dart';
import 'field_encryption.dart';

/// Repositório seguro para armazenamento de dados sensíveis
class SecureRepository {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Armazena um valor de forma segura
  static Future<void> secureStore(String key, String value,
      {String? userId}) async {
    await _secureStorage.write(key: key, value: value);

    if (userId != null) {
      await AuditLogger.log(
        action: 'secure_store',
        resource: 'secure_storage/$key',
        userId: userId,
      );
    }
  }

  /// Recupera um valor armazenado de forma segura
  static Future<String?> secureRetrieve(String key, {String? userId}) async {
    final value = await _secureStorage.read(key: key);

    if (userId != null && value != null) {
      await AuditLogger.log(
        action: 'secure_retrieve',
        resource: 'secure_storage/$key',
        userId: userId,
      );
    }

    return value;
  }

  /// Remove um valor armazenado de forma segura
  static Future<void> secureDelete(String key, {String? userId}) async {
    await _secureStorage.delete(key: key);

    if (userId != null) {
      await AuditLogger.log(
        action: 'secure_delete',
        resource: 'secure_storage/$key',
        userId: userId,
      );
    }
  }

  /// Armazena um objeto de forma segura
  static Future<void> secureStoreObject(String key, Map<String, dynamic> object,
      {String? userId}) async {
    // Criptografa campos sensíveis
    final encryptedObject = await _encryptSensitiveFields(object);

    // Converte para JSON e armazena
    final jsonString = json.encode(encryptedObject);
    await secureStore(key, jsonString, userId: userId);
  }

  /// Recupera um objeto armazenado de forma segura
  static Future<Map<String, dynamic>?> secureRetrieveObject(String key,
      {String? userId}) async {
    final jsonString = await secureRetrieve(key, userId: userId);
    if (jsonString == null) return null;

    // Converte de JSON e descriptografa
    final object = json.decode(jsonString) as Map<String, dynamic>;
    return _decryptSensitiveFields(object);
  }

  /// Criptografa campos sensíveis de um objeto
  static Future<Map<String, dynamic>> _encryptSensitiveFields(
      Map<String, dynamic> object) async {
    final result = Map<String, dynamic>.from(object);

    for (final entry in object.entries) {
      if (entry.value is String && FieldEncryption.shouldEncrypt(entry.key)) {
        result[entry.key] = await FieldEncryption.encrypt(entry.value);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = await _encryptSensitiveFields(entry.value);
      }
    }

    return result;
  }

  /// Descriptografa campos sensíveis de um objeto
  static Future<Map<String, dynamic>> _decryptSensitiveFields(
      Map<String, dynamic> object) async {
    final result = Map<String, dynamic>.from(object);

    for (final entry in object.entries) {
      if (entry.value is String && FieldEncryption.shouldEncrypt(entry.key)) {
        result[entry.key] = await FieldEncryption.decrypt(entry.value);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = await _decryptSensitiveFields(entry.value);
      }
    }

    return result;
  }
}
