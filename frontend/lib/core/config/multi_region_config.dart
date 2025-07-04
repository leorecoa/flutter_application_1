import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Configuração para suporte multi-região
class MultiRegionConfig {
  /// Regiões disponíveis
  static const Map<String, String> regions = {
    'us-east-1': 'Leste dos EUA (Norte da Virgínia)',
    'us-west-2': 'Oeste dos EUA (Oregon)',
    'sa-east-1': 'América do Sul (São Paulo)',
    'eu-west-1': 'Europa (Irlanda)',
    'ap-northeast-1': 'Ásia-Pacífico (Tóquio)',
  };
  
  /// Endpoints da API por região
  static const Map<String, String> apiEndpoints = {
    'us-east-1': 'https://api.us-east-1.agendafacil.com',
    'us-west-2': 'https://api.us-west-2.agendafacil.com',
    'sa-east-1': 'https://api.sa-east-1.agendafacil.com',
    'eu-west-1': 'https://api.eu-west-1.agendafacil.com',
    'ap-northeast-1': 'https://api.ap-northeast-1.agendafacil.com',
  };
  
  /// Região padrão
  static const String defaultRegion = 'us-east-1';
  
  /// Chave para armazenar a região preferida
  static const String _preferredRegionKey = 'preferred_region';
  
  /// Obtém a região preferida do usuário
  static Future<String> getPreferredRegion() async {
    try {
      // Verifica se há uma região armazenada localmente
      final prefs = await SharedPreferences.getInstance();
      final storedRegion = prefs.getString(_preferredRegionKey);
      
      if (storedRegion != null && regions.containsKey(storedRegion)) {
        return storedRegion;
      }
      
      // Se não houver região armazenada, tenta obter do CloudFront
      final region = await _getRegionFromCloudFront();
      if (region != null) {
        // Armazena a região para uso futuro
        await prefs.setString(_preferredRegionKey, region);
        return region;
      }
    } catch (e) {
      debugPrint('Erro ao obter região preferida: $e');
    }
    
    // Retorna a região padrão se não conseguir determinar
    return defaultRegion;
  }
  
  /// Define a região preferida do usuário
  static Future<void> setPreferredRegion(String region) async {
    if (!regions.containsKey(region)) {
      throw ArgumentError('Região inválida: $region');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferredRegionKey, region);
    } catch (e) {
      debugPrint('Erro ao definir região preferida: $e');
      rethrow;
    }
  }
  
  /// Obtém o endpoint da API para a região especificada
  static Future<String> getApiEndpoint({String? region}) async {
    final preferredRegion = region ?? await getPreferredRegion();
    return apiEndpoints[preferredRegion] ?? apiEndpoints[defaultRegion]!;
  }
  
  /// Verifica a saúde de todas as regiões
  static Future<Map<String, bool>> checkRegionsHealth() async {
    final results = <String, bool>{};
    
    for (final region in regions.keys) {
      try {
        final endpoint = apiEndpoints[region];
        if (endpoint == null) continue;
        
        final response = await http.get(
          Uri.parse('$endpoint/health'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        results[region] = response.statusCode == 200;
      } catch (e) {
        results[region] = false;
      }
    }
    
    return results;
  }
  
  /// Obtém a região com menor latência
  static Future<String> findLowestLatencyRegion() async {
    final latencies = <String, int>{};
    
    for (final region in regions.keys) {
      try {
        final endpoint = apiEndpoints[region];
        if (endpoint == null) continue;
        
        final start = DateTime.now();
        final response = await http.get(
          Uri.parse('$endpoint/health'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        final end = DateTime.now();
        
        if (response.statusCode == 200) {
          final latency = end.difference(start).inMilliseconds;
          latencies[region] = latency;
        }
      } catch (e) {
        // Ignora regiões com erro
      }
    }
    
    if (latencies.isEmpty) {
      return defaultRegion;
    }
    
    // Encontra a região com menor latência
    String? bestRegion;
    int? bestLatency;
    
    latencies.forEach((region, latency) {
      if (bestLatency == null || latency < bestLatency!) {
        bestRegion = region;
        bestLatency = latency;
      }
    });
    
    return bestRegion ?? defaultRegion;
  }
  
  /// Obtém a região do CloudFront
  static Future<String?> _getRegionFromCloudFront() async {
    try {
      // Verifica se há um header X-Preferred-Region definido pelo Lambda@Edge
      final response = await http.get(
        Uri.parse('https://app.agendafacil.com/api-region'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final region = data['region'];
        
        if (region != null && regions.containsKey(region)) {
          return region;
        }
      }
    } catch (e) {
      debugPrint('Erro ao obter região do CloudFront: $e');
    }
    
    return null;
  }
}