// lib/screens/play_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/config_provider.dart';
import '../widgets/async_image.dart';
import '../theme/app_theme.dart';
import 'qr_scanner_overlay.dart';

class PlaySessionScreen extends ConsumerStatefulWidget {
  final String? businessId;

  const PlaySessionScreen({super.key, this.businessId});

  @override
  ConsumerState<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends ConsumerState<PlaySessionScreen> {
  // State to toggle between "Start Scanning" UI and the actual Scanner
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    // CASE 1: Game Tab Mode (No businessId passed)
    if (widget.businessId == null) {
      // If actively scanning, show the Overlay INLINE (full body)
      // This keeps the bottom nav visible (assuming PlaySessionScreen is a tab)
      if (_isScanning) {
        return Scaffold(
          body: QRScannerOverlay(
            onClose: () {
               setState(() => _isScanning = false);
            },
          ),
        );
      }

      // Default "Start Game" Dashboard
      return Scaffold(
        backgroundColor: AppTheme.primaryPurple,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const Icon(
                            Icons.qr_code_scanner, 
                            size: 100, 
                            color: AppTheme.accentGreen
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'MONOPOLY GO',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scan a business QR code to check in, earn points, and unlock properties!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentGreen,
                                foregroundColor: AppTheme.primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                              onPressed: () {
                                 setState(() => _isScanning = true);
                              },
                              child: const Text(
                                'START SCANNING',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      );
    }

    // CASE 2: Property Card Mode (businessId passed)
    // This is used when navigating to a specific business verification context
    final businessAsync = ref.watch(businessByIdProvider(widget.businessId!));

    return Scaffold(
      appBar: AppBar(title: const Text('PROPERTY CARD')),
      body: businessAsync.when(
        data: (business) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Business "Hero" Header
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AsyncImage(
                  imageUrl: business?.heroImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(business?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              // The "VISIT" Action
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('CHECK IN TO WIN'),
                onPressed: () {
                   _openModalScanner(
                     context, 
                     business!.id, 
                     business.secretCode ?? 'SECRET', 
                     business.checkInPoints ?? 100
                   );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // Helper for Modal Mode (used in Property Card context)
  void _openModalScanner(BuildContext context, String? businessId, String? secret, int? points) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
         height: MediaQuery.of(context).size.height * 0.85, // Give it distinct modal feel
         child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: QRScannerOverlay(
              businessId: businessId,
              correctSecret: secret,
              pointsToAward: points,
              // No onClose logic needed, default pop works for modal
            ),
         ),
      ),
    );
  }
}