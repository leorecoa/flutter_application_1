import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.grey900,
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.grey900,
    height: 1.4,
    letterSpacing: -0.1,
  );
  
  // Body text
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.grey700,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey700,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.4,
  );
  
  // Labels
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey800,
    height: 1.4,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey700,
    height: 1.3,
  );
  
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
    height: 1.3,
  );
  
  // Button text
  static TextStyle get buttonLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
    letterSpacing: 0.2,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
    letterSpacing: 0.2,
  );
  
  // Caption
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey500,
    height: 1.3,
  );
  
  // Overline
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.grey500,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Special styles
  static TextStyle get logo => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get price => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
    height: 1.2,
  );
  
  static TextStyle get error => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.4,
  );
  
  // Navigation
  static TextStyle get navItem => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey700,
    height: 1.4,
  );
  
  static TextStyle get navItemActive => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.4,
  );
  
  // Card titles
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.grey800,
    height: 1.4,
    letterSpacing: -0.1,
  );
  
  // Stats
  static TextStyle get statValue => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.grey900,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get statLabel => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
    height: 1.3,
  );
  
  // Appointment styles
  static TextStyle get appointmentTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.3,
  );
  
  static TextStyle get appointmentTime => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.grey800,
    height: 1.2,
  );
  
  static TextStyle get appointmentClient => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.grey700,
    height: 1.4,
  );
  
  static TextStyle get appointmentService => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.4,
  );
}