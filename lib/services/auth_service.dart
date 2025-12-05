import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create a new user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': Timestamp.now(),
        'totalVisits': 0,
        'ownedProperties': [],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print(e.message);
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print(e.message);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
