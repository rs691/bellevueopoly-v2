import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import 'firestore_provider.dart';
// Provider to get all businesses from the Firestore Stream
final businessListProvider = StreamProvider<List<Business>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getBusinessesStream();
});

// Provider to get a single business by ID
// Provider to get a single business by ID from Firestore
// Provider to get a single business by ID from the stream
final businessByIdProvider = Provider.family<AsyncValue<Business?>, String>((ref, id) {
  final businessListAsync = ref.watch(businessListProvider);

  return businessListAsync.whenData((businesses) {
    try {
      return businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  });
});
