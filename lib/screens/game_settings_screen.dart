import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart'; // Import ThemeProvider
import '../router/app_router.dart';

class GameSettingsScreen extends ConsumerWidget {
  const GameSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioManager = ref.watch(audioManagerProvider);
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Display'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                themeNotifier.setTheme(newSelection.first);
              },
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, 'Audio'),
          SwitchListTile(
            title: const Text('Music'),
            subtitle: const Text('Background music'),
            value: audioManager.musicEnabled,
            onChanged: (value) => audioManager.toggleMusic(value),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Game sound effects'),
            value: audioManager.sfxEnabled,
            onChanged: (value) => audioManager.toggleSfx(value),
          ),
          const Divider(),

          _buildSectionHeader(context, 'Legal & Info'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.terms),
          ),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('Rules & Prizes'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push(AppRoutes.rulesAndPrizes),
          ),
          const AboutListTile(
             icon: Icon(Icons.info),
             applicationName: 'Bellevueopoly',
             applicationVersion: '1.0.0',
             applicationLegalese: '© 2024 Bellevueopoly',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}