import 'package:flutter/material.dart';

class LuxuryTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFF5E6A3);
  static const Color deepBlue = Color(0xFF0F1419);
  static const Color charcoal = Color(0xFF1A1D23);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color pearl = Color(0xFFF8F6F0);

  static ThemeData get luxuryTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryGold,
      secondary: darkGold,
      surface: pearl,
      background: pearl,
      onPrimary: deepBlue,
      onSecondary: pearl,
      onSurface: deepBlue,
      onBackground: deepBlue,
    ),
    scaffoldBackgroundColor: pearl,
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBlue,
      foregroundColor: primaryGold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryGold,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: deepBlue,
        elevation: 4,
        shadowColor: darkGold.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: platinum),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: platinum),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGold, width: 2),
      ),
      labelStyle: TextStyle(color: charcoal),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: deepBlue,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: deepBlue,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        color: deepBlue,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: charcoal,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: charcoal,
        height: 1.4,
      ),
    ),
  );

  static BoxDecoration get luxuryGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F1419),
        Color(0xFF1A1D23),
        Color(0xFF2D3748),
      ],
    ),
  );

  static LinearGradient get goldGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFB8860B),
      Color(0xFFDAA520),
    ],
  );
}