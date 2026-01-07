import 'package:flutter/material.dart';

class AppTheme {
  // --- Colors -- -
  static const Color primaryPurple = Color(0xFF2d1b4e);
  static const Color accentGreen = Color(0xFF4ade80);
  static const Color accentOrange = Color(0xFFf97316);
  static const Color navBarBackground = Color(0xFF1f1238);

  // --- Themes -- -
  static final ThemeData theme = ThemeData(
    useMaterial3: true, // Enable Material 3
    brightness: Brightness.dark,

    // Define a modern, M3 color scheme from a seed color
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.dark,
      primary: accentGreen, // Keep brand green as primary
      secondary: accentOrange, // Keep brand orange as secondary
    ).copyWith(
      surface: navBarBackground, // Ensure the nav bar color is used as the surface
    ),

    scaffoldBackgroundColor: primaryPurple,

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

    // Updated BottomNavigationBarTheme for M3
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      // The background color is now controlled by `colorScheme.surface`.
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accentGreen,
      unselectedItemColor: Colors.white70,
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
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      // In M3, Card color is derived from the color scheme.
      // This uses a color that is slightly lighter than the main surface.
      color: const Color(0xFF2a1d4a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

