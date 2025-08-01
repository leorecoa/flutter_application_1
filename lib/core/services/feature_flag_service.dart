import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/amplify_service.dart';

/// Classe para gerenciar feature flags
class FeatureFlagService {
  final AmplifyService _amplifyService;
  final String _apiEndpoint;
  Map<String, bool> _featureFlags = {};
  DateTime? _lastFetched;
  
  FeatureFlagService(this._amplifyService, {String? apiEndpoint})
      : _apiEndpoint = apiEndpoint ?? 'https://api.agendemais.com/feature-flags';
  
  /// Obtém o valor de uma feature flag
  bool isFeatureEnabled(String featureName, {bool defaultValue = false}) {
    return _featureFlags[featureName] ?? defaultValue;
  }
  
  /// Carrega as feature flags do servidor ou do cache local
  Future<Map<String, bool>> loadFeatureFlags({bool forceRefresh = false}) async {
    // Se não forçar atualização e tiver flags em cache recente (menos de 1 hora)
    if (!forceRefresh && 
        _featureFlags.isNotEmpty && 
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!).inMinutes < 60) {
      return _featureFlags;
    }
    
    try {
      // Tenta carregar do servidor
      final flags = await _fetchFromServer();
      _featureFlags = flags;
      _lastFetched = DateTime.now();
      
      // Salva no cache local
      await _saveToLocalCache(flags);
      
      return flags;
    } catch (e) {
      // Em caso de erro, tenta carregar do cache local
      final cachedFlags = await _loadFromLocalCache();
      if (cachedFlags.isNotEmpty) {
        _featureFlags = cachedFlags;
        return cachedFlags;
      }
      
      // Se não tiver cache, retorna flags padrão
      return _getDefaultFlags();
    }
  }
  
  /// Busca as feature flags do servidor
  Future<Map<String, bool>> _fetchFromServer() async {
    try {
      final token = await _amplifyService.getIdToken();
      
      final response = await http.get(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, bool>.from(data['features'] ?? {});
      } else {
        throw Exception('Falha ao carregar feature flags: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar feature flags: $e');
    }
  }
  
  /// Salva as feature flags no cache local
  Future<void> _saveToLocalCache(Map<String, bool> flags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('feature_flags', json.encode(flags));
      await prefs.setString('feature_flags_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      // Ignora erros ao salvar no cache
    }
  }
  
  /// Carrega as feature flags do cache local
  Future<Map<String, bool>> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flagsJson = prefs.getString('feature_flags');
      
      if (flagsJson != null) {
        final timestampStr = prefs.getString('feature_flags_timestamp');
        if (timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          // Verifica se o cache não está muito antigo (máximo 24 horas)
          if (DateTime.now().difference(timestamp).inHours < 24) {
            _lastFetched = timestamp;
            return Map<String, bool>.from(json.decode(flagsJson));
          }
        }
      }
      
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// Retorna as flags padrão para o caso de falha total
  Map<String, bool> _getDefaultFlags() {
    return {
      'enable_batch_operations': true,
      'enable_statistics': true,
      'enable_export': true,
      'enable_recurring_appointments': true,
      'enable_notifications': true,
      'enable_dark_mode': false,
      'enable_beta_features': false,
    };
  }
}

/// Provider para o serviço de feature flags
final featureFlagServiceProvider = Provider<FeatureFlagService>((ref) {
  final amplifyService = ref.watch(amplifyServiceProvider);
  return FeatureFlagService(amplifyService);
});

/// Provider para as feature flags carregadas
final featureFlagsProvider = FutureProvider<Map<String, bool>>((ref) async {
  final service = ref.watch(featureFlagServiceProvider);
  return service.loadFeatureFlags();
});

/// Provider para verificar se uma feature específica está habilitada
final isFeatureEnabledProvider = Provider.family<bool, String>((ref, featureName) {
  final flagsAsync = ref.watch(featureFlagsProvider);
  return flagsAsync.maybeWhen(
    data: (flags) => flags[featureName] ?? false,
    orElse: () => false,
  );
});