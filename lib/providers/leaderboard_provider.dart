import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../services/firestore_service.dart';

// Provides the FirestoreService instance.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// StreamProvider for the leaderboard.
final leaderboardProvider = StreamProvider<List<Player>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getLeaderboardStream();
});
