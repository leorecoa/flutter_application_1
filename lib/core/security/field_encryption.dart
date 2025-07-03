import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para criptografia em nível de campo
class FieldEncryption {
  static const String _keyName = 'encryption_key';
  static const String _ivName = 'encryption_iv';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static Encrypter? _encrypter;
  static IV? _iv;
  
  /// Inicializa o serviço de criptografia
  static Future<void> init() async {
    if (_encrypter != null) return;
    
    // Recupera ou gera chave de criptografia
    String? keyString = await _secureStorage.read(key: _keyName);
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = base64.encode(key.bytes);
      await _secureStorage.write(key: _keyName, value: keyString);
    }
    
    // Recupera ou gera vetor de inicialização
    String? ivString = await _secureStorage.read(key: _ivName);
    if (ivString == null) {
      final iv = IV.fromSecureRandom(16);
      ivString = base64.encode(iv.bytes);
      await _secureStorage.write(key: _ivName, value: ivString);
    }
    
    final key = Key(base64.decode(keyString));
    _iv = IV(base64.decode(ivString));
    _encrypter = Encrypter(AES(key));
  }
  
  /// Criptografa um valor
  static Future<String> encrypt(String value) async {
    await init();
    return _encrypter!.encrypt(value, iv: _iv!).base64;
  }
  
  /// Descriptografa um valor
  static Future<String> decrypt(String encrypted) async {
    await init();
    return _encrypter!.decrypt64(encrypted, iv: _iv!);
  }
  
  /// Gera um hash para um valor (não reversível)
  static String hash(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }
  
  /// Verifica se um campo deve ser criptografado
  static bool shouldEncrypt(String fieldName) {
    return _sensitiveFields.contains(fieldName);
  }
  
  /// Lista de campos sensíveis que devem ser criptografados
  static const Set<String> _sensitiveFields = {
    'cpf',
    'rg',
    'phone',
    'address',
    'creditCard',
    'medicalInfo',
    'personalNotes',
  };
}