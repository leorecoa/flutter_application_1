import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment_config.dart';
import '../logging/logger.dart';

/// Provider para o serviço de cache local
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheServiceImpl();
});

/// Interface para o serviço de cache local
abstract class LocalCacheService {
  /// Inicializa o serviço de cache
  Future<void> initialize();
  
  /// Obtém um valor do cache
  T? get<T>(String key);
  
  /// Define um valor no cache
  void set<T>(String key, T value, {Duration? expiration});
  
  /// Remove um valor do cache
  void remove(String key);
  
  /// Limpa todo o cache
  void clear();
  
  /// Verifica se uma chave existe no cache
  bool containsKey(String key);
  
  /// Verifica se uma chave está expirada
  bool isExpired(String key);
}

/// Implementação do serviço de cache local
class LocalCacheServiceImpl implements LocalCacheService {
  final Map<String, _CacheEntry> _cache = {};
  
  @override
  Future<void> initialize() async {
    Logger.info('Serviço de cache local inicializado');
  }
  
  @override
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      return null;
    }
    
    if (entry.isExpired()) {
      remove(key);
      return null;
    }
    
    return entry.value as T?;
  }
  
  @override
  void set<T>(String key, T value, {Duration? expiration}) {
    // Limita o tamanho do cache
    if (_cache.length >= EnvironmentConfig.maxCacheItems && !_cache.containsKey(key)) {
      _removeOldest();
    }
    
    final expirationTime = expiration != null
        ? DateTime.now().add(expiration)
        : DateTime.now().add(EnvironmentConfig.cacheExpiration);
    
    _cache[key] = _CacheEntry(value, expirationTime);
    
    Logger.debug('Item adicionado ao cache', context: {
      'key': key,
      'expiresAt': expirationTime.toIso8601String(),
    });
  }
  
  @override
  void remove(String key) {
    _cache.remove(key);
    Logger.debug('Item removido do cache', context: {'key': key});
  }
  
  @override
  void clear() {
    _cache.clear();
    Logger.info('Cache limpo');
  }
  
  @override
  bool containsKey(String key) {
    return _cache.containsKey(key) && !isExpired(key);
  }
  
  @override
  bool isExpired(String key) {
    final entry = _cache[key];
    return entry == null || entry.isExpired();
  }
  
  /// Remove o item mais antigo do cache
  void _removeOldest() {
    if (_cache.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.createdAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.createdAt;
      }
    }
    
    if (oldestKey != null) {
      remove(oldestKey);
    }
  }
}

/// Classe que representa uma entrada no cache
class _CacheEntry {
  _CacheEntry(this.value, this.expiresAt) : createdAt = DateTime.now();
  
  final dynamic value;
  final DateTime expiresAt;
  final DateTime createdAt;
  
  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }
}