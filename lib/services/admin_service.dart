import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing admin roles and permissions
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if the current user is an admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      return data?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Stream to watch admin status changes
  Stream<bool> adminStatusStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['isAdmin'] == true);
  }

  /// Grant admin privileges to a user
  Future<void> grantAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': true,
        'adminGrantedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to grant admin: $e');
    }
  }

  /// Revoke admin privileges from a user
  Future<void> revokeAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': false,
        'adminRevokedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to revoke admin: $e');
    }
  }

  /// Get all admin users
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get admins: $e');
    }
  }

  /// Check if a specific user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Make the current user admin (for development)
  Future<void> makeCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await grantAdmin(user.uid);
  }
}
