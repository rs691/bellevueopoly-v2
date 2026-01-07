import 'package:flutter/material.dart';

class AppTheme {
  // --- Colors -- -
  static const Color primaryPurple = Color(0xFF2d1b4e);
  static const Color accentGreen = Color(0xFF4ade80);
  static const Color accentOrange = Color(0xFFf97316);
  static const Color navBarBackground = Color(0xFF1f1238);

  // --- Themes -- -
  // --- Dark Theme (Existing) ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.dark,
      primary: accentGreen,
      secondary: accentOrange,
    ).copyWith(
      surface: navBarBackground,
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

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accentGreen,
      unselectedItemColor: Colors.white70,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      color: const Color(0xFF2a1d4a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // --- Light Theme (New) ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.light,
      primary: primaryPurple, // Use branding color as primary in light mode
      secondary: accentOrange,
    ).copyWith(
      surface: Colors.white,
      onSurface: Colors.black87,
    ),

    scaffoldBackgroundColor: const Color(0xFFF3E5F5), // Light Purple tint

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: primaryPurple,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryPurple),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryPurple,
      unselectedItemColor: Colors.black54,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
      titleMedium: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      labelSmall: TextStyle(color: Colors.black54),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPurple),
      ),
      hintStyle: const TextStyle(color: Colors.black38),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
