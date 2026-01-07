import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper to access shared preferences (initialized in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    // We can safely read this here because we override it in main.dart
    final prefs = ref.watch(sharedPreferencesProvider);
    return _getInitialTheme(prefs);
  }

  ThemeMode _getInitialTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    if (mode == ThemeMode.system) {
      prefs.remove(_themeKey);
    } else {
      prefs.setString(_themeKey, mode.name);
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(newMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
