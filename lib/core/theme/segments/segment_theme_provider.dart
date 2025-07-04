import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'business_segment.dart';

/// Provedor de temas específicos para cada segmento de negócio
class SegmentThemeProvider {
  /// Gera um tema completo baseado no segmento de negócio
  static ThemeData getThemeForSegment(BusinessSegment segment) {
    final primaryColor = segment.primaryColor;
    final secondaryColor = segment.secondaryColor;
    final backgroundColor = segment.backgroundColor;
    final fontFamily = segment.fontFamily;
    final borderRadius = segment.borderRadius;

    // Carrega a fonte do Google Fonts
    final textTheme = GoogleFonts.getTextTheme(
      fontFamily,
      const TextTheme().copyWith(
        displayLarge: TextStyle(color: primaryColor.withAlpha(204)),
        displayMedium: TextStyle(color: primaryColor.withAlpha(204)),
        displaySmall: TextStyle(color: primaryColor.withAlpha(204)),
      ),
    );

    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  /// Gera um tema escuro baseado no segmento de negócio
  static ThemeData getDarkThemeForSegment(BusinessSegment segment) {
    final primaryColor = segment.primaryColor;
    final secondaryColor = segment.secondaryColor;
    final fontFamily = segment.fontFamily;
    final borderRadius = segment.borderRadius;

    // Carrega a fonte do Google Fonts
    final textTheme = GoogleFonts.getTextTheme(
      fontFamily,
      const TextTheme().copyWith(
        displayLarge: const TextStyle(color: Colors.white70),
        displayMedium: const TextStyle(color: Colors.white70),
        displaySmall: const TextStyle(color: Colors.white70),
      ),
    );

    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
