import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Service for handling all Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a profile picture and update the user's Firestore document
  ///
  /// Images are stored in: `profile_pictures/{userId}/{timestamp}.jpg`
  /// Metadata is saved to the `images` collection in Firestore
  ///
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture(dynamic imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Create a unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp.jpg';
      final path = 'profile_pictures/${user.uid}/$fileName';

      // Create storage reference with explicit image metadata (prevents rule failures on web)
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // Upload file
      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, imageFile is Uint8List
        uploadTask = ref.putData(imageFile as Uint8List, metadata);
      } else {
        // For mobile, imageFile is File
        uploadTask = ref.putFile(imageFile as File, metadata);
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadUrl,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Also update Firebase Auth profile
      await user.updatePhotoURL(downloadUrl);

      // Save metadata to images collection so it appears in image gallery
      await _firestore.collection('images').add({
        'userId': user.uid,
        'imageUrl': downloadUrl,
        'storagePath': path,
        'category': 'profile',
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': DateTime.now().toIso8601String(),
      });

      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Profile picture upload failed: $e');
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('permission-denied')) {
        throw Exception(
          'Permission denied. Please check Firebase Storage rules and ensure you have upload permissions.',
        );
      }
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Upload multiple images (for business reviews, etc.)
  ///
  /// Images are stored in: `user_uploads/{userId}/{category}/{timestamp}_{index}.jpg`
  /// Metadata is saved to the `images` collection in Firestore
  ///
  /// Returns a list of download URLs
  Future<List<String>> uploadMultipleImages({
    required List<dynamic> imageFiles,
    String category = 'general',
    String? businessId,
    String? businessName,
    List<String>? tags,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final List<String> downloadUrls = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uploadDate = DateTime.now();

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = '${timestamp}_$i.jpg';
        final path = 'user_uploads/${user.uid}/$category/$fileName';
        final ref = _storage.ref().child(path);

        // Upload file with explicit image metadata (prevents rule failures on web)
        UploadTask uploadTask;
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        if (kIsWeb) {
          uploadTask = ref.putData(imageFiles[i] as Uint8List, metadata);
        } else {
          uploadTask = ref.putFile(imageFiles[i] as File, metadata);
        }

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        // Save metadata to Firestore images collection
        await _firestore.collection('images').add({
          'userId': user.uid,
          'imageUrl': downloadUrl,
          'storagePath': path,
          'category': category,
          'businessId': businessId,
          'businessName': businessName,
          'tags': tags ?? [],
          'uploadedAt': FieldValue.serverTimestamp(),
          'uploadedAtClient': uploadDate.toIso8601String(),
        });
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('❌ Multiple images upload failed: $e');
      debugPrint('Category: $category, User: ${user.uid}');
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('permission-denied')) {
        throw Exception(
          'Permission denied for category "$category". Check Firebase Storage rules and admin status.',
        );
      }
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Delete an image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('❌ Image deletion failed: $e');
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('permission-denied')) {
        throw Exception(
          'Permission denied. You may not have permission to delete this image.',
        );
      }
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete old profile pictures when a new one is uploaded
  /// This helps manage storage costs
  Future<void> deleteOldProfilePictures() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _storage.ref().child('profile_pictures/${user.uid}');
      final result = await ref.listAll();

      // Keep only the most recent file, delete others
      if (result.items.length > 1) {
        // Sort by creation time and keep the newest
        result.items.sort(
          (a, b) => b.name.compareTo(a.name),
        ); // Assuming timestamp-based names

        // Delete all but the first (newest) item
        for (int i = 1; i < result.items.length; i++) {
          await result.items[i].delete();
        }
      }
    } catch (e) {
      // Non-critical error, just log it
      print('Error cleaning old profile pictures: $e');
    }
  }

  /// Get the current user's profile picture URL from Firestore
  Future<String?> getProfilePictureUrl() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['photoURL'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get stream of user's uploaded images
  Stream<QuerySnapshot> getUserImagesStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    return _firestore
        .collection('images')
        .where('userId', isEqualTo: user.uid)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  /// Delete image and its Firestore metadata
  Future<void> deleteImageWithMetadata(
    String imageDocId,
    String imageUrl,
  ) async {
    try {
      // Delete from Storage
      await deleteImage(imageUrl);

      // Delete metadata from Firestore
      await _firestore.collection('images').doc(imageDocId).delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
