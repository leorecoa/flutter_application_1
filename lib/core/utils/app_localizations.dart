import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Classe para gerenciar a internacionalização do aplicativo
class AppLocalizations {
  /// Locale atual
  final Locale locale;
  
  /// Traduções carregadas
  Map<String, String> _localizedStrings = {};
  
  AppLocalizations(this.locale);
  
  /// Helper method para obter a instância atual através do InheritedWidget
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Delegate para carregar as traduções
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  /// Carrega as traduções do arquivo JSON
  Future<bool> load() async {
    // Carrega o arquivo JSON com as traduções
    final jsonString = await rootBundle.loadString(
      'assets/i18n/${locale.languageCode}.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    
    return true;
  }
  
  /// Traduz uma chave para o idioma atual
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

/// Delegate para carregar as traduções
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  /// Idiomas suportados
  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es'].contains(locale.languageCode);
  }
  
  /// Carrega as traduções
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  /// Sempre recarrega as traduções quando o locale muda
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extensão para facilitar o acesso às traduções
extension AppLocalizationsExtension on BuildContext {
  /// Traduz uma chave para o idioma atual
  String tr(String key) {
    return AppLocalizations.of(this).translate(key);
  }
}