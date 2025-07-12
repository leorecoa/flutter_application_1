import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _defaultTtl = Duration(minutes: 15);
  
  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(ttl ?? _defaultTtl);
    
    final cacheData = {
      'data': data,
      'expiry': expiry.millisecondsSinceEpoch,
    };
    
    await prefs.setString(key, jsonEncode(cacheData));
  }

  Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);
    
    if (cached == null) return null;
    
    try {
      final cacheData = jsonDecode(cached);
      final expiry = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
      
      if (DateTime.now().isAfter(expiry)) {
        await prefs.remove(key);
        return null;
      }
      
      return cacheData['data'] as T;
    } catch (e) {
      await prefs.remove(key);
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}