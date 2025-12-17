import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';

/// Stream of all businesses from Firestore 'businesses' collection
final firestoreBusinessesProvider = StreamProvider<List<Business>>((ref) {
  return FirebaseFirestore.instance.collection('businesses').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) {
          try {
            return Business.fromJson({...doc.data(), 'id': doc.id});
          } catch (e) {
            return null;
          }
        })
        .whereType<Business>()
        .toList();
  });
});

/// Single business by ID from Firestore
final firestoreBusinessByIdProvider = StreamProvider.family<Business?, String>((
  ref,
  id,
) {
  return FirebaseFirestore.instance
      .collection('businesses')
      .doc(id)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        try {
          return Business.fromJson({...doc.data()!, 'id': doc.id});
        } catch (e) {
          return null;
        }
      });
});
