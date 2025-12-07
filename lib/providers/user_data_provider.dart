import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

final userDataProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  final user = authState.asData?.value;
  if (user != null) {
    return firestoreService.getUserStream(user.uid);
  }
  return Stream.value(null);
});
