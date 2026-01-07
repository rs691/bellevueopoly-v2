import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For rootBundle
import '../models/business_model.dart';
import '../models/player.dart';

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
      // Check if user is anonymous (developer bypass)
      final isAnonymous = user.isAnonymous;
      
      await _db.collection('users').doc(user.uid).set({
        'username': username,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'totalVisits': 0,
        'total_points': 0,
        'propertiesOwned': [],
        'trophies': [],
        'isAdmin': isAnonymous, // Anonymous users get admin access
        'isAnonymous': isAnonymous,
      });
      
      if (isAnonymous) {
        debugPrint('✅ Anonymous user created with admin privileges');
      }
    } catch (e) {
      debugPrint('Error adding user to Firestore: $e');
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
      debugPrint('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  Future<void> incrementUserVisits(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({
        'totalVisits': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing user visits: $e');
      rethrow;
    }
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
      debugPrint("✅ Successfully uploaded ${businesses.length} businesses to Firestore!");
    } catch (e) {
      debugPrint("❌ Error seeding data: $e");
      rethrow;
    }
  }

  // 2. FETCH (Read from Cloud)
  // Used by the App to get businesses from Firestore instead of local JSON
  Stream<List<Business>> getBusinessesStream() {
    return _db.collection('businesses').snapshots().map((snapshot) {
      debugPrint("📢 Firestore Business Stream Update: ${snapshot.docs.length} documents found.");
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID matches doc ID
        try {
          return Business.fromJson(data);
        } catch (e) {
          debugPrint("❌ Error parsing business ${doc.id}: $e");
          rethrow;
        }
      }).toList();
    });
  }

  // Get Top Players for Leaderboard
  Stream<List<Player>> getTopPlayersStream({int limit = 20}) {
    return _db.collection('users')
        .orderBy('total_points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Handle potential parsing errors safely
        try {
          // If 'id' is missing in data, we added it. But Player.fromJson might expect other required fields.
          // We need to ensure data has what Player needs, or construct it manually.
          return Player.fromJson(data);
        } catch (e) {
          debugPrint("Error parsing player ${doc.id}: $e");
          // Return a placeholder so the stream doesn't crash
          return Player(
            id: doc.id, 
            name: data['username'] ?? 'Unknown', 
            balance: 0, 
            ownedPropertyIds: [], 
            totalVisits: (data['totalVisits'] as int?) ?? 0,
            totalPoints: (data['total_points'] as int?) ?? 0,
            createdAt: DateTime.now()
          );
        }
      }).toList();
    });
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
      debugPrint("❌ Error fetching users: $e");
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
      debugPrint("❌ Error fetching businesses: $e");
      rethrow;
    }
  }
}
