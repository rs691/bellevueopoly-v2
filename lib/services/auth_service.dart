import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Initialize auth persistence
  Future<void> initializeAuth() async {
    // Set persistence to LOCAL for both web and mobile
    await _auth.setPersistence(Persistence.LOCAL);
  }

  // Track last login
  Future<void> _saveLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastLogin', DateTime.now().toIso8601String());
    await prefs.setBool('hasLoggedIn', true);
  }

  // Check if user has logged in before
  Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasLoggedIn') ?? false;
  }

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create a new user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': Timestamp.now(),
        'totalVisits': 0,
        'ownedProperties': [],
      });

      await _saveLastLogin();
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
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveLastLogin();
      return result;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print(e.message);
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, use popup/redirect method
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final userCredential = await _auth.signInWithPopup(googleProvider);

        if (userCredential.user != null) {
          // Create or update user document in Firestore
          final userDoc = _firestore
              .collection('users')
              .doc(userCredential.user!.uid);
          final docSnapshot = await userDoc.get();

          if (!docSnapshot.exists) {
            await userDoc.set({
              'username': userCredential.user!.displayName ?? 'User',
              'email': userCredential.user!.email,
              'photoURL': userCredential.user!.photoURL,
              'createdAt': Timestamp.now(),
              'totalVisits': 0,
              'ownedProperties': [],
            });
          }

          await _saveLastLogin();
        }

        return userCredential;
      } else {
        // For mobile, would use google_sign_in package
        // TODO: Implement mobile Google Sign-In when needed
        throw UnsupportedError('Google Sign-In on mobile not yet implemented');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
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
