import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _statusLog = "Ready for Admin operations...\n";
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  // Helper to append text to the top of the log
  void _log(String message) {
    setState(() {
      _statusLog = "$message\n$_statusLog";
    });
  }

  void _clearLog() {
    setState(() {
      _statusLog = "Log cleared.\n";
    });
  }

  // --- FEATURE 1: Upload JSON to Firestore ---
  Future<void> _seedFirestore() async {
    setState(() => _isLoading = true);
    _log("\n🚀 STARTING UPLOAD...");
    try {
      await _firestoreService.seedFirestoreFromLocal();
      _log("✅ SUCCESS: Data seeding complete.");
    } catch (e) {
      _log("❌ ERROR: Upload failed. $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FEATURE 2: List Businesses (Formatted) ---
  Future<void> _listBusinesses() async {
    setState(() => _isLoading = true);
    _log("\n📂 FETCHING BUSINESSES...");
    try {
      final businesses = await _firestoreService.getBusinesses();

      if (businesses.isEmpty) {
        _log("⚠️ No businesses found in Firestore.");
      } else {
        StringBuffer buffer = StringBuffer();
        buffer.writeln("✅ LOADED ${businesses.length} BUSINESSES:");
        buffer.writeln("==========================================");

        for (var b in businesses) {
          buffer.writeln("📍 ${b.name}");
          buffer.writeln("   ID:       ${b.id}");
          buffer.writeln("   Category: ${b.category}");
          if (b.address != null) {
            // Truncate address if it's too long for the log
            String addr = b.address!.length > 40
                ? "${b.address!.substring(0, 37)}..."
                : b.address!;
            buffer.writeln("   Address:  $addr");
          }
          buffer.writeln("------------------------------------------");
        }
        buffer.writeln("==========================================");
        _log(buffer.toString());
      }
    } catch (e) {
      _log("❌ ERROR fetching businesses: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FEATURE 3: List Users (Formatted) ---
  Future<void> _listUsers() async {
    setState(() => _isLoading = true);
    _log("\n👥 FETCHING USERS...");
    try {
      final users = await _firestoreService.getUsers();

      if (users.isEmpty) {
        _log("⚠️ No users found in Firestore.");
      } else {
        StringBuffer buffer = StringBuffer();
        buffer.writeln("✅ LOADED ${users.length} USERS:");
        buffer.writeln("==========================================");

        for (var u in users) {
          final name = u['username'] ?? 'Unknown';
          final email = u['email'] ?? 'N/A';
          final uid = u['uid'] ?? 'N/A';
          final visits = u['totalVisits'] ?? 0;
          final created = u['createdAt'] != null
              ? (u['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
              : 'N/A';

          buffer.writeln("👤 $name");
          buffer.writeln("   Email:  $email");
          buffer.writeln("   UID:    $uid");
          buffer.writeln("   Visits: $visits");
          buffer.writeln("   Joined: $created");
          buffer.writeln("------------------------------------------");
        }
        buffer.writeln("==========================================");
        _log(buffer.toString());
      }
    } catch (e) {
      _log("❌ ERROR fetching users: $e");
    } finally {
      setState(() => _isLoading = false);
    }

  }

  // --- FEATURE 4: Show QR Codes ---
  Future<void> _showBusinessQRList() async {
    setState(() => _isLoading = true);
    try {
      final businesses = await _firestoreService.getBusinesses();
      if (businesses.isEmpty) {
        _log("⚠️ No businesses found.");
        return;
      }

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Select Business for QR"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: businesses.length,
              itemBuilder: (ctx, index) {
                final b = businesses[index];
                return ListTile(
                  title: Text(b.name),
                  subtitle: Text(b.secretCode ?? "No Secret"),
                  trailing: const Icon(Icons.qr_code),
                  onTap: () {
                    Navigator.pop(context); // Close list
                    _displayQRCode(b.name, b.secretCode);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("CLOSE")
            )
          ],
        ),
      );

    } catch (e) {
      _log("❌ Error loading businesses for QR: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _displayQRCode(String name, String? secret) {
    if (secret == null || secret.isEmpty) {
      _log("❌ Cannot generate QR: No secret code for $name");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(name, style: const TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 250,
              width: 250,
              child: QrImageView(
                data: secret,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Start Game -> Start Scanning",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
             SelectableText(
              "Secret: $secret",
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("DONE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin Console'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: "Clear Log",
              onPressed: _clearLog,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 32,
                      color: AppTheme.accentOrange,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Database Controls",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Manage users & business data",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions Section
              const Text(
                "DATA MANAGEMENT",
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Seed Database (Upload JSON)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  side: const BorderSide(color: AppTheme.accentOrange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _seedFirestore,
              ),

              const SizedBox(height: 24),

              // Testing Tools
              const Text(
                "TESTING TOOLS",
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text("Show Business QR Codes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _showBusinessQRList,
              ),

              const SizedBox(height: 24),

              // Inspection Section
              const Text(
                "INSPECTION",
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.store),
                      label: const Text("List Businesses"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoading ? null : _listBusinesses,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.people),
                      label: const Text("List Users"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoading ? null : _listUsers,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                "CONSOLE LOG",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Console Output
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          reverse: false,
                          child: Text(
                            _statusLog,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'Courier',
                              fontSize: 13,
                              height:
                                  1.2, // Slightly more spacing between lines
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

