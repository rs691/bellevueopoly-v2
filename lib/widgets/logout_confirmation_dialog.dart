import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// A reusable logout confirmation dialog with consistent styling
/// and error handling across the app.
class LogoutConfirmationDialog {
  /// Shows a confirmation dialog before logging out the user.
  /// Returns true if logout was successful, false if cancelled or failed.
  static Future<bool> show(BuildContext context) async {
    if (!context.mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // User cancelled
    if (confirmed != true) return false;

    if (!context.mounted) return false;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Attempt logout
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return true;

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to landing screen
      context.go('/landing');

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Successfully logged out'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return false;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Logout failed: ${e.message ?? "Unknown error"}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => show(context),
          ),
        ),
      );

      return false;
    } catch (e) {
      if (!context.mounted) return false;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show network error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Network error. Please check your connection.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => show(context),
          ),
        ),
      );

      return false;
    }
  }
}
