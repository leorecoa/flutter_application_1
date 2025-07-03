import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utilitário para armazenamento seguro de dados
class StorageUtils {
  static const String _businessIdKey = 'current_business_id';
  static const String _userIdKey = 'current_user_id';
  
  /// Obtém o ID do negócio atual
  static Future<String> getCurrentBusinessId() async {
    if (kIsWeb) {
      // No ambiente web, podemos usar localStorage
      // Mas como não temos acesso direto, usamos SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_businessIdKey) ?? '';
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_businessIdKey) ?? '';
    }
  }
  
  /// Define o ID do negócio atual
  static Future<void> setCurrentBusinessId(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessIdKey, businessId);
  }
  
  /// Obtém o ID do usuário atual
  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) ?? '';
  }
  
  /// Define o ID do usuário atual
  static Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }
  
  /// Limpa todos os dados armazenados (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}