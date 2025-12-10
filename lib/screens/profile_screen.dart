import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_data_provider.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Temporary function to upload business data
  Future<void> _uploadBusinessData(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Starting business data upload...')),
      );

      final firestore = FirebaseFirestore.instance;
      final businessesJson = await rootBundle.loadString('assets/data/businesses.json');
      final businesses = jsonDecode(businessesJson) as List<dynamic>;

      final batch = firestore.batch();
      for (var businessData in businesses) {
        final id = businessData['id'] as String;
        if (id.isNotEmpty) {
          final docRef = firestore.collection('businesses').doc(id);
          batch.set(docRef, businessData as Map<String, dynamic>);
        }
      }

      await batch.commit();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✓ Successfully uploaded all businesses to Firestore!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error uploading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final FirebaseAuth auth = FirebaseAuth.instance;

    return GradientBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: userData.when(
            data: (userDoc) {
              if (userDoc == null || !userDoc.exists) {
                // This can happen briefly on logout, so we show a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
              final user = userDoc.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(context, user),
                    const SizedBox(height: 24),
                    _buildStatsGrid(user),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context, auth),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    // Temporary Upload Button
                    ElevatedButton.icon(
                      onPressed: () => _uploadBusinessData(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Business Data (Temporary)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          )
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.accentGreen,
          child: Text(
            user.containsKey('username') ? user['username'][0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.containsKey('username') ? user['username'] : 'User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        Text(
          user.containsKey('email') ? user['email'] : '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> user) {
    final propertiesOwned = user.containsKey('propertiesOwned') ? user['propertiesOwned'] as List : [];
    final trophies = user.containsKey('trophies') ? user['trophies'] as List : [];
    final totalVisits = user.containsKey('totalVisits') ? user['totalVisits'] : 0;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _StatCard(title: 'Visits', value: totalVisits.toString()),
        _StatCard(title: 'Properties', value: propertiesOwned.length.toString()),
        _StatCard(title: 'Trophies', value: trophies.length.toString()),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, FirebaseAuth auth) {
    return ElevatedButton.icon(
      onPressed: () async {
        await auth.signOut();
        // Go back to the landing screen after logout.
        // The router's redirect logic will handle the rest.
        context.go('/landing');
      },
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
