import 'package:flutter/material.dart';

class KTColor {
  // Primary Colors
  static const Color primary = Color(0xFF00BA9B);
  static const Color primaryLight = Color(0xFF79CDB0);
  static const Color primaryDark = Color(0xFF009688);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Colors.white;
  static const Color surface = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textLight = Colors.white;
  
  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  
  // UI Elements
  static const Color border = Color(0xFFE0E0E0);
  static const Color iconPrimary = Color(0xFF009688);
  static const Color shadow = Color(0xFF000000);
  
  // Helper for alpha colors
  static Color primaryWithAlpha(double opacity) => primary.withValues(alpha: opacity);
  static Color errorWithAlpha(double opacity) => error.withValues(alpha: opacity);
  static Color shadowWithAlpha(double opacity) => shadow.withValues(alpha: opacity);
}
