import 'package:flutter/material.dart';

class AppColors {
  // Cores principais - Inspirado no Trinks/Zenklub
  static const Color primary = Color(0xFF6C63FF);      // Roxo principal
  static const Color secondary = Color(0xFF00C9A7);    // Verde água
  static const Color tertiary = Color(0xFFFF6584);     // Rosa
  static const Color accent = Color(0xFFFFBE0B);       // Amarelo

  // Cores neutras
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF9FAFC);   // Fundo claro
  static const Color grey50 = Color(0xFFF9FAFC);
  static const Color grey100 = Color(0xFFF1F4F8);
  static const Color grey200 = Color(0xFFE9ECF2);
  static const Color grey300 = Color(0xFFD8DCE3);
  static const Color grey400 = Color(0xFFC2C7D0);
  static const Color grey500 = Color(0xFF9AA1B1);
  static const Color grey600 = Color(0xFF646E82);      // Texto secundário
  static const Color grey700 = Color(0xFF424B5F);
  static const Color grey800 = Color(0xFF2D3445);      // Texto primário
  static const Color grey900 = Color(0xFF1D2333);
  
  // Cores de status
  static const Color success = Color(0xFF00C9A7);       // Verde
  static const Color warning = Color(0xFFFFBE0B);       // Amarelo
  static const Color error = Color(0xFFFF6584);         // Rosa/vermelho
  static const Color info = Color(0xFF6C63FF);          // Roxo
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF836FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, Color(0xFF00E6C3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [grey50, grey100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Gradiente para cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [white, grey50],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Cores específicas do PIX
  static const Color pixGreen = Color(0xFF00C9A7);
  static const Color pixBackground = Color(0xFFF0F8F7);
  
  // Sombras
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: black.withAlpha(13),  // 5% opacity
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: black.withAlpha(8),  // 3% opacity
      blurRadius: 25,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withAlpha(76),  // 30% opacity
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}