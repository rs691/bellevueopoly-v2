import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_box.dart';
import '../router/app_router.dart';

class MobileLandingScreen extends StatelessWidget {
  const MobileLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevents back button on home
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            // 1. Map Tab
            NavigationBox(
              icon: Icons.map,
              label: 'Stop Hub',
              onTap: () => context.go(AppRoutes.map),
            ),

            // 2. Business List Tab
            NavigationBox(
              icon: Icons.store,
              label: 'Boulevard Partners',
              onTap: () => context.go(AppRoutes.businesses),
            ),

            // 3. Upload Images (The new requested box)
            NavigationBox(
              icon: Icons.camera_alt,
              label: 'Upload Images',
              onTap: () => context.go(AppRoutes.upload),
            ),

            // 4. Admin Panel (Placeholder)
            NavigationBox(
              icon: Icons.emoji_events,
              label: 'Admin Panel',
              onTap: () => context.go(AppRoutes.admin),
              ),

            // 5. Profile Tab
            NavigationBox(
              icon: Icons.person,
              label: 'My Account',
              onTap: () => context.go(AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }
}
