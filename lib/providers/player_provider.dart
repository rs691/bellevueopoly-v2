import 'package:flutter_riverpod/legacy.dart';
import '../models/index.dart';

// Current player state
final playerProvider = StateNotifierProvider<PlayerNotifier, Player?>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<Player?> {
  PlayerNotifier() : super(null);

  void setPlayer(Player player) {
    state = player;
  }

  void updateBalance(int newBalance) {
    if (state != null) {
      state = state!.copyWith(balance: newBalance);
    }
  }

  void addVisit() {
    if (state != null) {
      state = state!.copyWith(totalVisits: state!.totalVisits + 1);
    }
  }

  void claimProperty(String propertyId) {
    if (state != null) {
      final updated = state!.ownedPropertyIds + [propertyId];
      state = state!.copyWith(ownedPropertyIds: updated);
    }
  }
}
