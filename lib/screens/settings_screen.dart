import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_background.dart';
import '../router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Account'),
            _buildSettingsCard([
              _buildListTile(context, 'Edit Profile', Icons.person_outline),
              _buildListTile(context, 'Change Password', Icons.lock_outline),
              _buildListTile(
                context,
                'Check-in History',
                Icons.history,
                onTap: () => context.push(AppRoutes.checkinHistory),
              ),
              _buildListTile(
                context,
                'Logout',
                Icons.exit_to_app,
                isDestructive: true,
                onTap: () => _handleLogout(context),
              ),
              _buildListTile(
                context,
                'Delete Account',
                Icons.delete_forever_outlined,
                isDestructive: true,
                onTap: () => _handleDeleteAccount(context),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Notifications'),
            _buildSettingsCard([
              SwitchListTile(
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                value: true,
                onChanged: (val) {},
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
              SwitchListTile(
                title: const Text(
                  'Email Updates',
                  style: TextStyle(color: Colors.white),
                ),
                value: false,
                onChanged: (val) {},
                secondary: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Other'),
            _buildSettingsCard([
              _buildListTile(
                context,
                'How to Play',
                Icons.menu_book_outlined,
                onTap: () => context.push(AppRoutes.instructions),
              ),
              _buildListTile(
                context,
                'Privacy Policy',
                Icons.privacy_tip_outlined,
              ),
              _buildListTile(context, 'Terms of Service', Icons.gavel_outlined),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white70,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      context.go('/landing');
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and sign you out. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently signed in.')),
        );
      }
      return;
    }

    // Show a blocking progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = user.uid;

      // Delete device documents (best-effort)
      final devices = await firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .get();
      for (final doc in devices.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await firestore.collection('users').doc(uid).delete();

      // Delete auth user
      await user.delete();

      // Ensure sign out (no confirmation needed - already confirmed for account deletion)
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.of(context).pop(); // close progress dialog
        context.go('/landing');
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'requires-recent-login'
          ? 'Please log in again, then retry deleting your account.'
          : 'Delete failed: ${e.message ?? e.code}';
      if (context.mounted) {
        Navigator.of(context).pop(); // close progress
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
}
