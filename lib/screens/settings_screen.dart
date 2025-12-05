import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

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
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Account'),
            _buildSettingsCard([
              _buildListTile(context, 'Edit Profile', Icons.person_outline),
              _buildListTile(context, 'Change Password', Icons.lock_outline),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Notifications'),
            _buildSettingsCard([
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                value: true,
                onChanged: (val) {},
                secondary: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
              SwitchListTile(
                title: const Text('Email Updates', style: TextStyle(color: Colors.white)),
                value: false,
                onChanged: (val) {},
                secondary: const Icon(Icons.email_outlined, color: Colors.white),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Other'),
            _buildSettingsCard([
              _buildListTile(context, 'Privacy Policy', Icons.privacy_tip_outlined),
              _buildListTile(context, 'Terms of Service', Icons.gavel_outlined),
              _buildListTile(context, 'Logout', Icons.exit_to_app, isDestructive: true),
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
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Colors.white70, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(children: children),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        // Handle tap
      },
    );
  }
}
