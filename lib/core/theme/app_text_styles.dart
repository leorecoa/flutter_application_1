import 'package:flutter/material.dart';

/// Estilos de texto do aplicativo
class AppTextStyles {
  /// Título principal
  static TextStyle get h1 => heading1;
  
  /// Título secundário
  static TextStyle get h2 => heading2;
  
  /// Título terciário
  static TextStyle get h3 => heading3;
  
  /// Título quaternário
  static TextStyle get h4 => heading4;
  
  /// Título quinário
  static TextStyle get h5 => heading5;
  
  /// Corpo de texto médio
  static TextStyle get bodyMedium => body1;
  
  /// Corpo de texto grande
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Corpo de texto pequeno
  static TextStyle get bodySmall => caption;
  
  /// Rótulo grande
  static TextStyle get labelLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  /// Rótulo médio
  static TextStyle get labelMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  /// Rótulo pequeno
  static TextStyle get labelSmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  /// Estilo para botão grande
  static TextStyle get buttonLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  /// Estilo para botão médio
  static TextStyle get buttonMedium => button;
  
  /// Estilo para item de navegação ativo
  static TextStyle get navItemActive => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  /// Estilo para item de navegação
  static TextStyle get navItem => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  /// Estilo para título de card
  static TextStyle get cardTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  /// Estilo para valores estatísticos
  static TextStyle get statValue => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  /// Estilo para preços
  static TextStyle get price => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  /// Estilo para logo
  static TextStyle get logo => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Estilo para mensagens de erro
  static TextStyle get error => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Colors.red,
  );

  /// Título principal
  static TextStyle get heading1 => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Título secundário
  static TextStyle get heading2 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Título terciário
  static TextStyle get heading3 => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Título quaternário
  static TextStyle get heading4 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Título quinário
  static TextStyle get heading5 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// Subtítulo
  static TextStyle get subtitle1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Subtítulo menor
  static TextStyle get subtitle2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Corpo de texto principal
  static TextStyle get body1 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Corpo de texto secundário
  static TextStyle get body2 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Texto pequeno
  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  /// Texto de botão
  static TextStyle get button => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.5,
  );
}