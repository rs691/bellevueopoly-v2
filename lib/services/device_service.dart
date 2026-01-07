import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles per-installation device IDs and registration in Firestore.
class DeviceService {
  static const _prefsKey = 'installationId';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a stable installation ID, creating and persisting it if needed.
  Future<String> getOrCreateInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final newId = _generateInstallationId();
    await prefs.setString(_prefsKey, newId);
    return newId;
  }

  /// Registers or refreshes the current device under users/{uid}/devices/{installationId}.
  Future<void> registerDeviceForUser(User user, {String? fcmToken}) async {
    final installationId = await getOrCreateInstallationId();

    final data = <String, dynamic>{
      'deviceId': installationId,
      'platform': _platformLabel(),
      'lastSeen': FieldValue.serverTimestamp(),
    };

    if (fcmToken != null && fcmToken.isNotEmpty) {
      data['fcmToken'] = fcmToken;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(installationId)
        .set(data, SetOptions(merge: true));
  }

  /// Generates a pseudo-random installation ID (no extra dependency).
  String _generateInstallationId() {
    final random = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final bytes = List<int>.generate(12, (_) => random.nextInt(256));
    final encoded = base64Url.encode(bytes).replaceAll('=', '');
    return '$timestamp-$encoded';
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }
}
