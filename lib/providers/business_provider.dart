import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';

// Provider to get all businesses from Firestore
final businessListProvider = FutureProvider<List<Business>>((ref) async {
  final firestoreService = FirestoreService();
  return firestoreService.getBusinesses();
});

// Provider to get a single business by ID from Firestore
final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final firestoreService = FirestoreService();
  return firestoreService.getBusinessById(id);
});
