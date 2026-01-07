import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/logout_confirmation_dialog.dart';

class MyAccountOptionsScreen extends ConsumerWidget {
  const MyAccountOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
                // You can replace this with a user profile image
                // backgroundImage: NetworkImage('https://example.com/user_image.jpg'),
              ),
              const SizedBox(height: 20),
              Text(
                'User Name', // Replace with actual user name
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'user.email@example.com', // Replace with actual user email
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: const Text('Edit Profile'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Profile tapped')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: const Text('Change Password'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Change Password tapped'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('App Settings'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App Settings tapped')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => LogoutConfirmationDialog.show(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
