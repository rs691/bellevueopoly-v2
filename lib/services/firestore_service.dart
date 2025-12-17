import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For rootBundle
import '../models/business_model.dart';
import '../models/player.dart'; // Import Player model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==============================================================================
  // SECTION 1: USER LOGIC (Authentication & Player Data)
  // ==============================================================================

  Future<void> addUser({
    required User user,
    required String username,
  }) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'id': user.uid, // Store ID in document
        'name': username,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'totalVisits': 0,
        'balance': 0, // Initial points/balance
        'ownedPropertyIds': [],
        'trophies': [],
      });
    } catch (e) {
      print('Error adding user to Firestore: $e');
      rethrow;
    }
  }

  // Returns a real-time stream of the user's document.
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Deprecated: Use getUserStream for real-time updates.
  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      print('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  Future<void> incrementUserVisits(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'totalVisits': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing user visits: $e');
      rethrow;
    }
  }

  // Add points to a user's balance
  Future<void> addPoints(String uid, int points) async {
    try {
      await _db.collection('users').doc(uid).update({
        'balance': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error adding points: $e');
      // If document doesn't exist or field is missing, set it
      // This is a fallback, but ideally user doc exists.
    }
  }

  // Fetch Leaderboard (Top players by balance)
  Stream<List<Player>> getLeaderboardStream({int limit = 10}) {
    return _db.collection('users')
        .orderBy('balance', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is present
        // Handle potential missing fields gracefully
        return Player.fromJson({
          ...data,
          'name': data['name'] ?? 'Unknown Player',
          'balance': data['balance'] ?? 0,
          'ownedPropertyIds': data['ownedPropertyIds'] ?? [],
          'totalVisits': data['totalVisits'] ?? 0,
          'createdAt': data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String() 
              : DateTime.now().toIso8601String(),
        });
      }).toList();
    });
  }

  // ==============================================================================
  // SECTION 2: BUSINESS LOGIC (Map Data & Seeding)
  // ==============================================================================

  // 1. UPLOAD (Migration Tool)
  // This reads your local JSON and pushes it to Firestore
  Future<void> seedFirestoreFromLocal() async {
    try {
      // Load local JSON
      final jsonString = await rootBundle.loadString('assets/data/config.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Handle the map structure
      final List<dynamic> businesses = jsonData['businesses'];

      final batch = _db.batch();

      for (var b in businesses) {
        // We use the 'id' from JSON as the Document ID in Firestore
        final docRef = _db.collection('businesses').doc(b['id']);
        batch.set(docRef, b);
      }

      await batch.commit();
      print("✅ Successfully uploaded ${businesses.length} businesses to Firestore!");
    } catch (e) {
      print("❌ Error seeding data: $e");
      rethrow;
    }
  }

  // 2. FETCH (Read from Cloud)
  // Used by the App to get businesses from Firestore instead of local JSON
  Stream<List<Business>> getBusinessesStream() {
    return _db.collection('businesses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID matches doc ID
        return Business.fromJson(data);
      }).toList();
    });
  }

  Future<Business?> getBusinessById(String id) async {
    try {
      final doc = await _db.collection('businesses').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return Business.fromJson(data);
    } catch (e) {
      print("❌ Error fetching business $id: $e");
      return null;
    }
  }

  // ==============================================================================
  // SECTION 3: ADMIN LOGIC
  // ==============================================================================

  // 1. FETCH USERS (Future - One-time fetch)
  // Fetches all documents from the 'users' collection for the Admin Panel
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Attach the ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("❌ Error fetching users: $e");
      rethrow;
    }
  }

  // 2. FETCH BUSINESSES (Future - One-time fetch)
  // Added for the Admin Console "List Businesses" button
  Future<List<Business>> getBusinesses() async {
    try {
      final snapshot = await _db.collection('businesses').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Business.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching businesses: $e");
      rethrow;
    }
  }

  // ==============================================================================
  // SECTION 5: CHECK-IN TRACKING (Loyalty Program)
  // ==============================================================================

  /// Record a visit/check-in to a business
  Future<void> recordCheckIn(String userId, String businessId) async {
    try {
      final userRef = _db.collection('users').doc(userId);

      // Increment total check-ins for this business
      await userRef.collection('businessCheckIns').doc(businessId).set(
        {
          'count': FieldValue.increment(1),
          'lastCheckIn': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Also update user's totalVisits
      await userRef.update({
        'totalVisits': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error recording check-in: $e');
      rethrow;
    }
  }

  /// Get the number of check-ins for a specific business
  Future<int> getBusinessCheckIns(String userId, String businessId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('businessCheckIns')
          .doc(businessId)
          .get();

      if (doc.exists) {
        return doc.data()?['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting business check-ins: $e');
      return 0;
    }
  }

  /// Get all check-ins for a user across all businesses
  Future<Map<String, int>> getAllBusinessCheckIns(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('businessCheckIns')
          .get();

      final result = <String, int>{};
      for (final doc in snapshot.docs) {
        result[doc.id] = doc.data()['count'] as int? ?? 0;
      }
      return result;
    } catch (e) {
      print('Error getting all business check-ins: $e');
      return {};
    }
  }
}
