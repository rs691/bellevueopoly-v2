import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}
