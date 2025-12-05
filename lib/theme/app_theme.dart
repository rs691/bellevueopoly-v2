import 'package:flutter/material.dart';

class AppTheme {
  // --- Colors -- -
  static const Color primaryPurple = Color(0xFF2d1b4e);
  static const Color accentGreen = Color(0xFF4ade80);
  static const Color accentOrange = Color(0xFFf97316);
  static const Color navBarBackground = Color(0xFF1f1238);

  // --- Themes -- -
  static final ThemeData theme = ThemeData(
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: primaryPurple,
    colorScheme: const ColorScheme.dark(
      primary: accentGreen,
      secondary: accentOrange,
      surface: navBarBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: navBarBackground,
      selectedItemColor: accentGreen,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white60),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
