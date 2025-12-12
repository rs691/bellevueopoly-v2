import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For rootBundle
import '../models/business_model.dart';

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
        'username': username,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'totalVisits': 0,
        'propertiesOwned': [],
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
}
