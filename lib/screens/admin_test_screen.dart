import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/admin_provider.dart';

/// Simple screen to test admin status and permissions
class AdminTestScreen extends ConsumerWidget {
  const AdminTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Status Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Auth Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Signed In: ${user != null ? "Yes" : "No"}'),
                    if (user != null) ...[
                      Text('UID: ${user.uid}'),
                      Text('Email: ${user.email ?? "N/A"}'),
                      Text('Anonymous: ${user.isAnonymous}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Admin Status from Provider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Status (Provider)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    isAdminAsync.when(
                      data: (isAdmin) => Text(
                        'Is Admin: ${isAdmin ? "YES ✓" : "NO ✗"}',
                        style: TextStyle(
                          color: isAdmin ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Text('Loading...'),
                      error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Check Firestore Document
            if (user != null)
              ElevatedButton(
                onPressed: () async {
                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Firestore User Document'),
                          content: SingleChildScrollView(
                            child: Text(
                              doc.exists 
                                ? 'Data: ${doc.data()}'
                                : 'Document does not exist!',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Check Firestore User Doc'),
              ),
            
            const SizedBox(height: 16),
            
            // Manual Admin Grant
            if (user != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'isAdmin': true});
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Admin status granted! Restart app to see changes.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Manually Grant Admin Status'),
              ),
          ],
        ),
      ),
    );
  }
}
