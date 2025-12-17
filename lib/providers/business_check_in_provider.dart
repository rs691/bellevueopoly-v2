import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Track check-ins for a specific business by the current user
final businessCheckInsProvider = FutureProvider.family<int, String>((ref, businessId) async {
  final userAsync = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreServiceProvider);

  final user = userAsync.value;
  if (user == null) return 0;

  try {
    // This assumes you have a method in FirestoreService to get check-ins
    // You'll need to implement this
    final checkIns = await firestore.getBusinessCheckIns(user.uid, businessId);
    return checkIns;
  } catch (e) {
    return 0;
  }
});

// Track all check-ins for the current user (useful for showing owned properties)
final userCheckInsProvider = FutureProvider<Map<String, int>>((ref) async {
  final userAsync = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreServiceProvider);

  final user = userAsync.value;
  if (user == null) return {};

  try {
    final checkIns = await firestore.getAllBusinessCheckIns(user.uid);
    return checkIns;
  } catch (e) {
    return {};
  }
});
