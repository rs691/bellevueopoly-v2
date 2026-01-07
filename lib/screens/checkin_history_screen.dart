import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../widgets/async_image.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';
import 'dart:math' as math;

class CheckinHistoryScreen extends StatelessWidget {
  const CheckinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your check-ins.')),
      );
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    final scansStream = FirebaseFirestore.instance
        .collection('scans')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('scanned_at', descending: true)
        .snapshots();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Check-in History'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: userDocStream,
          builder: (context, userSnap) {
            final userData = userSnap.data?.data() as Map<String, dynamic>?;
            final name = userData?['username'] as String? ?? 'Unknown';
            final email = userData?['email'] as String? ?? '';
            final lastLogin = user.metadata.lastSignInTime;

            return Column(
              children: [
                _UserInfoCard(
                  name: name,
                  email: email,
                  lastLogin: lastLogin,
                  totalPoints: userData?['total_points'] as int? ?? 0,
                  totalVisits: userData?['totalVisits'] as int? ?? 0,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: scansStream,
                    builder: (context, scanSnap) {
                      if (scanSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (scanSnap.hasError) {
                        return Center(child: Text('Error: ${scanSnap.error}'));
                      }
                      final docs = scanSnap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('No check-ins yet.'));
                      }
                      return FutureBuilder<Map<String, _BizMeta>>(
                        future: _resolveBusinessMeta(docs),
                        builder: (context, metaSnap) {
                          final metaMap = metaSnap.data ?? const {};

                          return ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final businessId = data['business_id'] as String? ?? 'Unknown business';
                              final meta = metaMap[businessId];
                              final businessName = meta?.name ?? businessId;
                              final addressLine = meta?.address ?? '';
                              final imageUrl = meta?.imageUrl;
                              final category = meta?.category;
                              final points = data['points_awarded'] ?? 0;
                              final ts = (data['scanned_at'] ?? data['timestamp']) as Timestamp?;
                              final dateStr = ts != null ? _format(ts.toDate()) : 'Unknown time';

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 20, end: 0),
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                builder: (context, offset, child) {
                                  return Transform.translate(
                                    offset: Offset(0, offset),
                                    child: Opacity(
                                      opacity: 1 - (offset / 20).clamp(0, 1),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    onTap: () => context.push('${AppRoutes.stopHub}/business/$businessId'),
                                    leading: ClipOval(
                                      child: AsyncImage(
                                        imageUrl: imageUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(businessName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _pill(dateStr),
                                            const SizedBox(width: 6),
                                            if (category != null && category.isNotEmpty)
                                              _pill(category, color: Colors.white24),
                                          ],
                                        ),
                                        if (addressLine.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(addressLine, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('+$points', style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                                          const Text('points', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, _BizMeta>> _resolveBusinessMeta(List<QueryDocumentSnapshot> docs) async {
    final ids = <String>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final bid = data['business_id'] as String?;
      if (bid != null && bid.isNotEmpty) ids.add(bid);
    }
    if (ids.isEmpty) return {};

    final result = <String, _BizMeta>{};
    final chunks = ids.toList();

    // Firestore whereIn supports up to 10 items; chunk accordingly
    for (var i = 0; i < chunks.length; i += 10) {
      final slice = chunks.sublist(i, i + 10 > chunks.length ? chunks.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('businesses')
          .where(FieldPath.documentId, whereIn: slice)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['name'] ?? data['title'] ?? doc.id).toString();
        final imageUrl = data['heroImageUrl'] as String?;
        final street = data['street'] as String?;
        final city = data['city'] as String?;
        final state = data['state'] as String?;
        final zip = data['zip'] as String?;
        final category = data['category'] as String?;
        final address = _formatAddress(street, city, state, zip);
        result[doc.id] = _BizMeta(name: name, address: address, imageUrl: imageUrl, category: category);
      }
    }
    return result;
  }

  String _formatAddress(String? street, String? city, String? state, String? zip) {
    final parts = [
      if (street != null && street.isNotEmpty) street,
      [if (city != null && city.isNotEmpty) city, if (state != null && state.isNotEmpty) state]
          .where((e) => e != null && e.isNotEmpty)
          .join(', '),
      if (zip != null && zip.isNotEmpty) zip,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(' · ');
  }

  String _format(DateTime dt) {
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hh:$mm';
  }
}

class _UserInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final DateTime? lastLogin;
  final int totalPoints;
  final int totalVisits;

  const _UserInfoCard({
    required this.name,
    required this.email,
    required this.lastLogin,
    required this.totalPoints,
    required this.totalVisits,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              children: [
                _pill('Points: $totalPoints'),
                const SizedBox(width: 8),
                _pill('Visits: $totalVisits'),
              ],
            ),
            if (lastLogin != null) ...[
              const SizedBox(height: 8),
              Text('Last login: ${_format(lastLogin!)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  String _format(DateTime dt) {
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hh:$mm';
  }
}

Widget _pill(String text, {Color? color}) {
  final bg = color ?? Colors.white.withOpacity(0.12);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
  );
}

class _BizMeta {
  final String name;
  final String address;
  final String? imageUrl;
  final String? category;
  const _BizMeta({required this.name, required this.address, this.imageUrl, this.category});
}
