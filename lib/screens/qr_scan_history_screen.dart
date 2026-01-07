import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/qr_scan.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

final qrScansProvider = StreamProvider.autoDispose.family<List<QrScan>, String>(
  (ref, playerId) {
    return FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .collection('qrScans')
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => QrScan.fromFirestore(doc)).toList();
        });
  },
);

class QrScanHistoryScreen extends ConsumerStatefulWidget {
  final String playerId;

  const QrScanHistoryScreen({super.key, required this.playerId});

  @override
  ConsumerState<QrScanHistoryScreen> createState() =>
      _QrScanHistoryScreenState();
}

class _QrScanHistoryScreenState extends ConsumerState<QrScanHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final qrScansAsync = ref.watch(qrScansProvider(widget.playerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scan History'),
        centerTitle: true,
        elevation: 0,
      ),
      body: qrScansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (scans) {
          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No QR scans yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Scan QR codes at businesses to start earning points',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.check_circle, color: AppColors.success),
                  ),
                  title: Text(
                    scan.businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(scan.scannedAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        if (scan.notes != null && scan.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              scan.notes!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${scan.pointsEarned}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Text('pts', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
