import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/router/app_router.dart'; // KEEP this as your primary router import
import 'firebase_options.dart';
import '../services/config_service.dart';
import '../theme/app_theme.dart'; // Add this import for AppTheme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService().initialize('assets/data/config.json');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Bellevueopoly',
      theme: AppTheme.theme, // Now AppTheme.theme should be recognized
      routerConfig: router,
    );
  }
}