import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/index.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class BusinessListScreen extends ConsumerWidget {
  const BusinessListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('All Businesses'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: businessesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (businesses) {
            return ListView.builder(
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                final business = businesses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: AppTheme.navBarBackground.withOpacity(0.8),
                  child: ListTile(
                    title: Text(business.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(business.category, style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    onTap: () => context.go('/business/${business.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
