import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/segments/business_segment.dart';
import '../../../core/theme/segments/segment_theme_provider.dart';
import '../models/white_label_config.dart';

/// Serviço para gerenciamento de configurações de white label
class WhiteLabelService {
  static const String _configCacheKey = 'white_label_config';
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/white-label';
  
  static WhiteLabelConfig? _cachedConfig;
  
  /// Obtém a configuração de white label para o tenant atual
  static Future<WhiteLabelConfig> getConfig(String tenantId) async {
    // Verifica se já existe em cache
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }
    
    try {
      // Tenta carregar do armazenamento local
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_configCacheKey);
      
      if (cachedJson != null) {
        _cachedConfig = WhiteLabelConfig.fromJson(json.decode(cachedJson));
        return _cachedConfig!;
      }
      
      // Se não encontrou localmente, busca da API
      final response = await http.get(
        Uri.parse('$_baseUrl/config/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
      );
      
      if (response.statusCode == 200) {
        final configJson = json.decode(response.body);
        final config = WhiteLabelConfig.fromJson(configJson);
        
        // Salva em cache local
        await prefs.setString(_configCacheKey, json.encode(configJson));
        
        _cachedConfig = config;
        return config;
      } else {
        throw Exception('Falha ao obter configuração: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, retorna uma configuração padrão baseada no segmento
      return _getDefaultConfig(tenantId);
    }
  }
  
  /// Atualiza a configuração de white label
  static Future<WhiteLabelConfig> updateConfig(String tenantId, WhiteLabelConfig config) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/config/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode(config.toJson()),
      );
      
      if (response.statusCode == 200) {
        final updatedConfig = WhiteLabelConfig.fromJson(json.decode(response.body));
        
        // Atualiza o cache
        _cachedConfig = updatedConfig;
        
        // Atualiza o armazenamento local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_configCacheKey, json.encode(updatedConfig.toJson()));
        
        return updatedConfig;
      } else {
        throw Exception('Falha ao atualizar configuração: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, mantém a configuração atual
      return config;
    }
  }
  
  /// Limpa o cache de configuração
  static Future<void> clearCache() async {
    _cachedConfig = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configCacheKey);
  }
  
  /// Gera um tema baseado na configuração de white label
  static ThemeData getTheme(WhiteLabelConfig config) {
    // Obtém o tema base do segmento
    final baseTheme = SegmentThemeProvider.getThemeForSegment(config.segment);
    
    // Personaliza o tema com as configurações de white label
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: config.primaryColor,
        secondary: config.secondaryColor ?? baseTheme.colorScheme.secondary,
        surface: config.backgroundColor ?? baseTheme.colorScheme.surface,
      ),
      textTheme: config.fontFamily != null
          ? _getCustomTextTheme(baseTheme.textTheme, config.fontFamily!)
          : baseTheme.textTheme,
    );
  }
  
  /// Gera um tema escuro baseado na configuração de white label
  static ThemeData getDarkTheme(WhiteLabelConfig config) {
    // Obtém o tema escuro base do segmento
    final baseTheme = SegmentThemeProvider.getDarkThemeForSegment(config.segment);
    
    // Personaliza o tema com as configurações de white label
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: config.primaryColor,
        secondary: config.secondaryColor ?? baseTheme.colorScheme.secondary,
      ),
      textTheme: config.fontFamily != null
          ? _getCustomTextTheme(baseTheme.textTheme, config.fontFamily!)
          : baseTheme.textTheme,
    );
  }
  
  /// Gera um TextTheme personalizado com a fonte especificada
  static TextTheme _getCustomTextTheme(TextTheme baseTheme, String fontFamily) {
    return baseTheme.apply(
      fontFamily: fontFamily,
    );
  }
  
  /// Gera uma configuração padrão baseada no segmento
  static WhiteLabelConfig _getDefaultConfig(String tenantId) {
    // Para fins de demonstração, determina o segmento com base no ID do tenant
    final segmentIndex = tenantId.hashCode % BusinessSegment.values.length;
    final segment = BusinessSegment.values[segmentIndex];
    
    return WhiteLabelConfig(
      companyName: 'AgendaFácil',
      primaryColor: segment.primaryColor,
      segment: segment,
      welcomeText: 'Bem-vindo ao AgendaFácil para ${segment.displayName}',
    );
  }
}