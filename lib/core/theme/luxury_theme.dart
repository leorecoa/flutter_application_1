import 'package:flutter/material.dart';

class LuxuryTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFF5E6A3);
  static const Color deepBlue = Color(0xFF1A237E);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color pearl = Color(0xFFF8F6F0);

  static final ThemeData luxuryTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: lightGold,
      surface: charcoal,
      onPrimary: deepBlue,
      onSecondary: deepBlue,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: deepBlue,
        elevation: 8,
        shadowColor: darkGold.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGold.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGold.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGold, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    cardTheme: const CardThemeData(
      elevation: 8,
      margin: EdgeInsets.all(8),
    ),
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      headlineMedium:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, charcoal],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, darkGold],
  );

  static BoxDecoration get luxuryContainer => const BoxDecoration(
        gradient: luxuryGradient,
      );
}
