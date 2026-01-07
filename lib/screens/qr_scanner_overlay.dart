import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class QRScannerOverlay extends StatefulWidget {
  final String? businessId;
  final String? correctSecret;
  final int? pointsToAward;
  final VoidCallback? onClose; // Custom callback for closing (e.g. switching state)

  const QRScannerOverlay({
    super.key,
    this.businessId,
    this.correctSecret,
    this.pointsToAward,
    this.onClose,
  });

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String scannedValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    // controller.stop(); // Don't strictly stop, just pause processing or UI
    // Stopping causes black screen sometimes. We just ignore further events via _isProcessing.

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
    }

    try {
      final db = FirebaseFirestore.instance;
      String targetBusinessId;
      int points = widget.pointsToAward ?? 100;

      debugPrint('🔍 QR Detected: $scannedValue');
      
      // ... (existing mode selection logic) ...
      // Mode A: Direct Verification (Business ID provided)
      if (widget.businessId != null && widget.correctSecret != null) {
        if (scannedValue != widget.correctSecret) {
          throw 'Invalid QR Code for this business.';
        }
        targetBusinessId = widget.businessId!;
      } 
      // Mode B: Generic Verification (Lookup by Secret)
      else {
        debugPrint('🔎 Looking up business by secret...');
        final querySnapshot = await db
            .collection('businesses')
            .where('secretCode', isEqualTo: scannedValue)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'Invalid QR Code. No matching business found.';
        }

        final businessDoc = querySnapshot.docs.first;
        final data = businessDoc.data();
        targetBusinessId = businessDoc.id;
        debugPrint('✅ Found business: $targetBusinessId');
        
        // Safe parsing for points
        final dynamic rawPoints = data['checkInPoints'];
        if (rawPoints is int) {
          points = rawPoints;
        } else if (rawPoints is String) {
          points = int.tryParse(rawPoints) ?? 100;
        } else {
          points = 100;
        }
      }

      final scanRef = db.collection('scans').doc('${user.uid}_$targetBusinessId');



      debugPrint('🔄 Checking for existing check-in...');
      // Alternative: Read-then-Write (Batch) instead of Transaction to avoid Web "converted Future" bugs
      final scanDoc = await scanRef.get();
      if (scanDoc.exists) throw 'You have already checked in here!';

      debugPrint('📝 Creating batch operation...');
      final batch = db.batch();

      // Get device information (with safe fallbacks for web)
      String deviceInfo = 'Unknown Device';
      String deviceId = 'unknown';
      String platform = 'unknown';
      
      try {
        // Web doesn't support Platform APIs
        if (kIsWeb) {
          deviceInfo = 'Web Browser';
          deviceId = 'web_browser';
          platform = 'web';
        } else {
          platform = Platform.operatingSystem;
          final deviceInfoPlugin = DeviceInfoPlugin();
          
          if (Platform.isAndroid) {
            try {
              final androidInfo = await deviceInfoPlugin.androidInfo;
              deviceInfo = '${androidInfo.manufacturer} ${androidInfo.model}';
              deviceId = androidInfo.id;
            } catch (e) {
              debugPrint('⚠️ Android info failed: $e');
              deviceInfo = 'Android Device';
            }
          } else if (Platform.isIOS) {
            try {
              final iosInfo = await deviceInfoPlugin.iosInfo;
              deviceInfo = '${iosInfo.name} ${iosInfo.model}';
              deviceId = iosInfo.identifierForVendor ?? 'unknown';
            } catch (e) {
              debugPrint('⚠️ iOS info failed: $e');
              deviceInfo = 'iOS Device';
            }
          } else if (Platform.isWindows) {
            try {
              final windowsInfo = await deviceInfoPlugin.windowsInfo;
              deviceInfo = windowsInfo.computerName;
              deviceId = windowsInfo.deviceId;
            } catch (e) {
              debugPrint('⚠️ Windows info failed: $e');
              deviceInfo = 'Windows Device';
            }
          } else if (Platform.isLinux) {
            try {
              final linuxInfo = await deviceInfoPlugin.linuxInfo;
              deviceInfo = linuxInfo.name;
              deviceId = linuxInfo.machineId ?? 'unknown';
            } catch (e) {
              debugPrint('⚠️ Linux info failed: $e');
              deviceInfo = 'Linux Device';
            }
          } else if (Platform.isMacOS) {
            try {
              final macInfo = await deviceInfoPlugin.macOsInfo;
              deviceInfo = macInfo.model;
              deviceId = macInfo.systemGUID ?? 'unknown';
            } catch (e) {
              debugPrint('⚠️ macOS info failed: $e');
              deviceInfo = 'Mac Device';
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Could not get device info: $e');
        deviceInfo = 'Unknown Device';
        deviceId = 'unknown';
      }

      debugPrint('📱 Device: $deviceInfo ($deviceId) - $platform');

      // 1. Create the scan record with enhanced metadata
      batch.set(scanRef, {
        'user_id': user.uid,
        'scanned_by': user.email ?? user.displayName ?? 'Unknown User',
        'scanned_by_username': user.displayName ?? user.email?.split('@')[0] ?? 'Unknown',
        'business_id': targetBusinessId,
        'scanned_at': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(), // Keep for backward compatibility
        'points_awarded': points,
        'device_info': deviceInfo,
        'device_id': deviceId,
        'platform': platform,
      });

      debugPrint('👤 Queuing user stats update...');
      // 2. Update user's total points and visit count
      // Using update() implies the user doc matches user.uid which should exist.
      // If user doc logic is fragile, we could use set(..., SetOptions(merge: true))
      batch.update(db.collection('users').doc(user.uid), {
        'total_points': FieldValue.increment(points),
        'totalVisits': FieldValue.increment(1),
      });

      debugPrint('🚀 Committing batch...');
      await batch.commit();
      debugPrint('✅ Batch committed successfully.');

      // Log Analytics
      final String businessName = widget.businessId != null 
          ? 'Business (${widget.businessId})' 
          : 'Business ($targetBusinessId)'; 

      try {
        debugPrint('📊 Logging Analytics...');
        await AnalyticsService().logCheckIn(
          businessId: targetBusinessId,
          businessName: businessName,
          points: points,
        );
        debugPrint('✅ Analytics Logged.');
      } catch (analyticsError) {
        debugPrint('⚠️ Analytics Failed (Non-fatal): $analyticsError');
      }

      if (mounted) _showSuccessUI(points);
    } catch (e, stack) {
      debugPrint('❌ Scan Error: $e\n$stack'); // Logic to print detailed error
      // Check if it's that specific "converted Future" error
      if (e.toString().contains('converted Future')) {
         if (mounted) _showErrorUI('Network/Database Error. Please try again.');
      } else {
         if (mounted) _showErrorUI('Error: ${e.toString()}');
      }
    } finally {
      // If we didn't succeed (error was thrown), we might want to resume scanning
      // logic is handled in _showErrorUI for resume.
      // If success, _showSuccessUI handles navigation/reset.
    }
  }

  void _showSuccessUI(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.9),
        title: const Icon(Icons.stars, color: AppTheme.accentGreen, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CHECK-IN SUCCESSFUL!', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              '+$points POINTS', 
              style: const TextStyle(color: AppTheme.accentGreen, fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.of(ctx).pop(); // Close Dialog using its own context
               _closeScanner();
            }, 
            child: const Text('BACK TO BOARD', style: TextStyle(color: Colors.white))
          )
        ],
      ),
    );
  }

  void _showErrorUI(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
    ));
    
    Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
           setState(() => _isProcessing = false);
        }
    });
  }

  void _closeScanner() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      // Default behavior if no callback (e.g. used in modal)
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for center cutout
    final scanWindowSize = 280.0;

    return Stack(
      children: [
        // 1. Camera View
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (capture.barcodes.isEmpty) return;
            final barcode = capture.barcodes.first;
            if (barcode.rawValue != null) _handleScan(barcode.rawValue!);
          },
        ),

        // 2. Dark Overlay with Cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5), 
            BlendMode.srcOut // Key: Cuts out the destination (the Container below)
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
               Container(
                 decoration: const BoxDecoration(
                   color: Colors.black,
                   backgroundBlendMode: BlendMode.dstOut,
                 ),
               ),
               Center(
                 child: Container(
                   width: scanWindowSize,
                   height: scanWindowSize,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(20),
                   ),
                 ),
               ),
            ],
          ),
        ),

        // 3. Visual Border & Decor
        Center(
          child: Container(
            width: scanWindowSize,
            height: scanWindowSize,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.accentGreen, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_scanner, 
                color: Colors.white24, 
                size: 100
              )
            ),
          ),
        ),

        // 4. Instructional Text
        Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: 0,
          right: 0,
          child: const Column(
            children: [
              Text(
                'SCAN TO CHECK-IN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Align the QR code within the frame',
                style: TextStyle(color: Colors.white70, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
              ),
            ],
          ),
        ),

        // 5. Close Button
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            onPressed: _closeScanner,
            icon: const CircleAvatar(
              backgroundColor: Colors.black45,
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}