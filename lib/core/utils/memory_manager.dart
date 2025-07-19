import 'dart:async';
import 'package:flutter/foundation.dart';

/// Classe utilitária para gerenciar a memória do aplicativo
class MemoryManager {
  /// Singleton instance
  static final MemoryManager _instance = MemoryManager._internal();
  
  /// Construtor de fábrica para retornar a instância singleton
  factory MemoryManager() => _instance;
  
  /// Construtor interno
  MemoryManager._internal();
  
  /// Cache de objetos
  final Map<String, _CacheEntry> _cache = {};
  
  /// Tamanho máximo do cache (em número de itens)
  int maxCacheSize = 100;
  
  /// Tempo de expiração padrão para itens do cache (em minutos)
  int defaultExpirationMinutes = 30;
  
  /// Timer para limpeza periódica do cache
  Timer? _cleanupTimer;
  
  /// Inicia o gerenciador de memória
  void initialize() {
    // Inicia o timer de limpeza periódica
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      cleanupCache();
    });
  }
  
  /// Adiciona um item ao cache
  void cacheObject<T>(String key, T object, {int? expirationMinutes}) {
    // Se o cache estiver cheio, remove o item mais antigo
    if (_cache.length >= maxCacheSize) {
      final oldestKey = _findOldestCacheEntry();
      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
    
    final expiration = DateTime.now().add(
      Duration(minutes: expirationMinutes ?? defaultExpirationMinutes),
    );
    
    _cache[key] = _CacheEntry<T>(
      value: object,
      createdAt: DateTime.now(),
      expiresAt: expiration,
    );
  }
  
  /// Obtém um item do cache
  T? getCachedObject<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      return null;
    }
    
    // Verifica se o item expirou
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    
    // Atualiza o timestamp de acesso
    entry.lastAccessed = DateTime.now();
    
    return entry.value as T;
  }
  
  /// Remove um item do cache
  void removeCachedObject(String key) {
    _cache.remove(key);
  }
  
  /// Limpa todo o cache
  void clearCache() {
    _cache.clear();
  }
  
  /// Limpa itens expirados do cache
  void cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      if (now.isAfter(entry.value.expiresAt)) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    
    if (kDebugMode && keysToRemove.isNotEmpty) {
      print('MemoryManager: Removidos ${keysToRemove.length} itens expirados do cache');
    }
  }
  
  /// Encontra a chave do item mais antigo no cache
  String? _findOldestCacheEntry() {
    if (_cache.isEmpty) {
      return null;
    }
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.lastAccessed;
      }
    }
    
    return oldestKey;
  }
  
  /// Libera recursos
  void dispose() {
    _cleanupTimer?.cancel();
    clearCache();
  }
}

/// Classe para armazenar um item no cache
class _CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime expiresAt;
  DateTime lastAccessed;
  
  _CacheEntry({
    required this.value,
    required this.createdAt,
    required this.expiresAt,
  }) : lastAccessed = DateTime.now();
}