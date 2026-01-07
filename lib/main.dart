import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPrefs
import '../router/app_router.dart';
import 'firebase_options.dart';
import '../services/config_service.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService().initialize('assets/data/config.json');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firebase Auth persistence
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Bellevueopoly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
