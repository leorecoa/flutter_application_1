import 'package:flutter/material.dart';

class TrinksTheme {
  // Paleta Trinks
  static const Color navyBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color lightPurple = Color(0xFFE0E7FF);
  static const Color darkGray = Color(0xFF374151);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static final ThemeData modernTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: navyBlue,
      secondary: purple,
      onSecondary: white,
      onSurface: darkGray,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: darkGray,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      iconTheme: IconThemeData(color: darkGray),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: darkGray.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: navyBlue,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: navyBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: darkGray, fontFamily: 'Inter'),
      hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Inter'),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkGray,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        color: darkGray,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        color: darkGray,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        color: darkGray,
        fontSize: 16,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        color: darkGray,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
    ),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkGray.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get gradientBackground => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightGray, white],
        ),
      );
}
