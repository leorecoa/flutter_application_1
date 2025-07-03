import 'package:flutter/material.dart';

/// Tipos de segmentos de negócio suportados
enum BusinessSegment {
  salon,
  clinic,
  spa,
  gym,
  restaurant,
  generic,
}

/// Extensão para obter informações sobre o segmento de negócio
extension BusinessSegmentExtension on BusinessSegment {
  /// Retorna o nome amigável do segmento
  String get displayName {
    switch (this) {
      case BusinessSegment.salon:
        return 'Salão de Beleza';
      case BusinessSegment.clinic:
        return 'Clínica';
      case BusinessSegment.spa:
        return 'Spa';
      case BusinessSegment.gym:
        return 'Academia';
      case BusinessSegment.restaurant:
        return 'Restaurante';
      case BusinessSegment.generic:
        return 'Negócio';
    }
  }
  
  /// Retorna o ícone associado ao segmento
  IconData get icon {
    switch (this) {
      case BusinessSegment.salon:
        return Icons.content_cut;
      case BusinessSegment.clinic:
        return Icons.medical_services;
      case BusinessSegment.spa:
        return Icons.spa;
      case BusinessSegment.gym:
        return Icons.fitness_center;
      case BusinessSegment.restaurant:
        return Icons.restaurant;
      case BusinessSegment.generic:
        return Icons.business;
    }
  }
  
  /// Retorna a cor primária recomendada para o segmento
  Color get primaryColor {
    switch (this) {
      case BusinessSegment.salon:
        return const Color(0xFF9C27B0); // Roxo
      case BusinessSegment.clinic:
        return const Color(0xFF2196F3); // Azul
      case BusinessSegment.spa:
        return const Color(0xFF4CAF50); // Verde
      case BusinessSegment.gym:
        return const Color(0xFFFF5722); // Laranja
      case BusinessSegment.restaurant:
        return const Color(0xFFF44336); // Vermelho
      case BusinessSegment.generic:
        return const Color(0xFF607D8B); // Azul acinzentado
    }
  }
  
  /// Retorna a cor secundária recomendada para o segmento
  Color get secondaryColor {
    switch (this) {
      case BusinessSegment.salon:
        return const Color(0xFFE91E63); // Rosa
      case BusinessSegment.clinic:
        return const Color(0xFF03A9F4); // Azul claro
      case BusinessSegment.spa:
        return const Color(0xFF8BC34A); // Verde claro
      case BusinessSegment.gym:
        return const Color(0xFFFF9800); // Laranja claro
      case BusinessSegment.restaurant:
        return const Color(0xFFFF9800); // Laranja
      case BusinessSegment.generic:
        return const Color(0xFF9E9E9E); // Cinza
    }
  }
  
  /// Retorna a cor de fundo recomendada para o segmento
  Color get backgroundColor {
    switch (this) {
      case BusinessSegment.salon:
        return const Color(0xFFF3E5F5); // Roxo claro
      case BusinessSegment.clinic:
        return const Color(0xFFE3F2FD); // Azul claro
      case BusinessSegment.spa:
        return const Color(0xFFE8F5E9); // Verde claro
      case BusinessSegment.gym:
        return const Color(0xFFFBE9E7); // Laranja claro
      case BusinessSegment.restaurant:
        return const Color(0xFFFFEBEE); // Vermelho claro
      case BusinessSegment.generic:
        return const Color(0xFFECEFF1); // Azul acinzentado claro
    }
  }
  
  /// Retorna a fonte recomendada para o segmento
  String get fontFamily {
    switch (this) {
      case BusinessSegment.salon:
        return 'Playfair Display';
      case BusinessSegment.clinic:
        return 'Montserrat';
      case BusinessSegment.spa:
        return 'Quicksand';
      case BusinessSegment.gym:
        return 'Roboto Condensed';
      case BusinessSegment.restaurant:
        return 'Lora';
      case BusinessSegment.generic:
        return 'Roboto';
    }
  }
  
  /// Retorna o estilo de bordas recomendado para o segmento
  double get borderRadius {
    switch (this) {
      case BusinessSegment.salon:
        return 16.0; // Mais arredondado
      case BusinessSegment.clinic:
        return 8.0; // Moderado
      case BusinessSegment.spa:
        return 24.0; // Muito arredondado
      case BusinessSegment.gym:
        return 4.0; // Quase quadrado
      case BusinessSegment.restaurant:
        return 12.0; // Moderado
      case BusinessSegment.generic:
        return 8.0; // Padrão
    }
  }
}