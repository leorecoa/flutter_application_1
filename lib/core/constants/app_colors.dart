import 'package:flutter/material.dart';

/// Constantes de cores para o aplicativo
class AppColors {
  // Cores primárias
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Cores secundárias
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Cores de status de agendamento
  static const Color scheduled = Color(0xFFFFA726);
  static const Color confirmed = Color(0xFF42A5F5);
  static const Color completed = Color(0xFF66BB6A);
  static const Color cancelled = Color(0xFFEF5350);
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Cores de fundo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Cores de tema escuro
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Cores de gradiente
  static const List<Color> primaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF2196F3),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFF57C00),
    Color(0xFFFF9800),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF388E3C),
    Color(0xFF4CAF50),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFD32F2F),
    Color(0xFFF44336),
  ];
  
  // Cores de sombra
  static const Color shadow = Color(0x1A000000);
  
  // Cores de overlay
  static const Color overlay = Color(0x80000000);
  
  // Função para obter cor de status de agendamento
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'agendado':
        return scheduled;
      case 'confirmado':
        return confirmed;
      case 'concluído':
        return completed;
      case 'cancelado':
        return cancelled;
      default:
        return info;
    }
  }
  
  // Função para obter cor com opacidade
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}