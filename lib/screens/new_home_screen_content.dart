import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:myapp/providers/auth_provider.dart'; // Import authStateProvider
import 'package:myapp/widgets/navigation_box.dart'; // Import NavigationBox

class NewHomeScreenContent extends ConsumerWidget { // Changed to ConsumerWidget
  const NewHomeScreenContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    final authState = ref.watch(authStateProvider);
    final String? username = authState.when(
      data: (user) => user?.displayName ?? user?.email?.split('@').first ?? 'Guest',
      loading: () => 'Loading...',
      error: (err, stack) => 'Error',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, ${username ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  NavigationBox(
                    icon: Icons.star,
                    label: 'Stop Hub',
                    onTap: () => context.go('/stop_hub'),
                  ),
                  NavigationBox(
                    icon: Icons.people,
                    label: 'Near Me',
                    onTap: () => context.go('/near_me'),
                  ),
                  NavigationBox(
                    icon: Icons.emoji_events,
                    label: 'Prizes',
                    onTap: () => context.go('/prizes'),
                  ),
                  NavigationBox(
                    icon: Icons.help_outline,
                    label: 'FAQ',
                    onTap: () => context.go('/faq'),
                  ),
                  NavigationBox(
                    icon: Icons.person,
                    label: 'My Account',
                    onTap: () => context.go('/my_account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
