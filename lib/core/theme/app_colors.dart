import 'package:flutter/material.dart';

class AppColors {
  // Cores principais - Inspirado no Trinks
  static const Color primary = Color(0xFF0455BF); // Azul royal
  static const Color secondary = Color(0xFF7452FF); // Roxo claro
  static const Color accent = Color(0xFF00D4AA); // Verde água
  
  // Cores neutras
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F4);
  static const Color grey200 = Color(0xFFE8EAED);
  static const Color grey300 = Color(0xFFDADCE0);
  static const Color grey400 = Color(0xFFBDC1C6);
  static const Color grey500 = Color(0xFF9AA0A6);
  static const Color grey600 = Color(0xFF80868B);
  static const Color grey700 = Color(0xFF5F6368);
  static const Color grey800 = Color(0xFF3C4043);
  static const Color grey900 = Color(0xFF202124);
  
  // Cores de status
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE8EAED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Cores específicas do PIX
  static const Color pixGreen = Color(0xFF32BCAD);
  static const Color pixBackground = Color(0xFFF0F8F7);
}