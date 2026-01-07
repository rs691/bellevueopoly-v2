import 'package:flutter/material.dart';

/// Centralized color palette for the app
class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryPurple = Color(0xFF9C27B0);

  // Secondary colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF424242);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFBDBDBD);
  static const Color veryLightGrey = Color(0xFFEEEEEE);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Game colors
  static const Color monopolyRed = Color(0xFFE53935);
  static const Color monopolyBlue = Color(0xFF1976D2);
  static const Color monopolyGreen = Color(0xFF388E3C);
  static const Color monopolyYellow = Color(0xFFFDD835);

  // Gradient backgrounds
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, Color(0xFF43A047)],
  );

  static const LinearGradient gradientWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, Color(0xFFE65100)],
  );
}
