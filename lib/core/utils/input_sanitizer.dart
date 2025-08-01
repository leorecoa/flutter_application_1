import 'package:flutter/material.dart';

/// Utilitário para sanitização e validação de inputs
class InputSanitizer {
  /// Sanitiza texto removendo caracteres potencialmente perigosos
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;
    
    // Remove caracteres especiais potencialmente perigosos para injeção
    return input.trim().replaceAll(RegExp(r'[^\w\s@.,;:\/\-\(\)]+'), '');
  }
  
  /// Sanitiza números de telefone
  static String sanitizePhone(String input) {
    if (input.isEmpty) return input;
    
    // Remove tudo exceto dígitos
    return input.replaceAll(RegExp(r'[^\d]+'), '');
  }
  
  /// Sanitiza emails
  static String sanitizeEmail(String input) {
    if (input.isEmpty) return input;
    
    // Trim e lowercase
    final sanitized = input.trim().toLowerCase();
    
    // Verifica se é um email válido
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(sanitized)) {
      return ''; // Retorna vazio se não for um email válido
    }
    
    return sanitized;
  }
  
  /// Sanitiza valores monetários
  static String sanitizeCurrency(String input) {
    if (input.isEmpty) return input;
    
    // Remove tudo exceto dígitos, vírgula e ponto
    return input.replaceAll(RegExp(r'[^\d.,]+'), '');
  }
  
  /// Converte string sanitizada para double
  static double? parseCurrency(String input) {
    if (input.isEmpty) return null;
    
    // Sanitiza primeiro
    final sanitized = sanitizeCurrency(input);
    
    // Converte vírgula para ponto
    final normalized = sanitized.replaceAll(',', '.');
    
    // Tenta converter para double
    try {
      return double.parse(normalized);
    } catch (e) {
      return null;
    }
  }
  
  /// Cria um TextInputFormatter para sanitização em tempo real
  static TextInputFormatter getTextSanitizer() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final sanitized = sanitizeText(newValue.text);
      return TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    });
  }
  
  /// Cria um TextInputFormatter para sanitização de telefone em tempo real
  static TextInputFormatter getPhoneSanitizer() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final sanitized = sanitizePhone(newValue.text);
      return TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    });
  }
}