import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceService _deviceService = DeviceService();

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

      // Register the device for this newly created user (non-blocking on errors)
      try {
        await _deviceService.registerDeviceForUser(userCredential.user!);
      } catch (e) {
        debugPrint('Device registration error (signUp): $e');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      debugPrint('Auth Error: ${e.message}');
      rethrow; // Rethrow to allow caller to handle with proper error messages
    } catch (e) {
      debugPrint('Unexpected error during sign up: $e');
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Register or refresh the device entry for this user
      try {
        await _deviceService.registerDeviceForUser(credential.user!);
      } catch (e) {
        debugPrint('Device registration error (signIn): $e');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      debugPrint('Auth Error: ${e.message}');
      rethrow; // Rethrow to allow caller to handle with proper error messages
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign in anonymously (Guest/Developer Bypass)
  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      // Register device even for anonymous users (useful for demo/testing)
      try {
        await _deviceService.registerDeviceForUser(credential.user!);
      } catch (e) {
        debugPrint('Device registration error (signInAnonymously): $e');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth Error: ${e.message}');
      return null;
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email verification error: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error sending verification: $e');
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Reload user to check if email is verified
  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Reload error: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error checking verification: $e');
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Check if current user's email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Get error message from FirebaseAuthException
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Check if error is network-related
  bool isNetworkError(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed';
    }
    return error.toString().toLowerCase().contains('network');
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
