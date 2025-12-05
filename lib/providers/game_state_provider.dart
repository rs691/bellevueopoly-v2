import 'package:flutter_riverpod/legacy.dart';
import '../models/index.dart';

// Game state - track properties and ownership
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, Map<String, Property>>((ref) {
      return GameStateNotifier();
    });

class GameStateNotifier extends StateNotifier<Map<String, Property>> {
  GameStateNotifier() : super({});

  void initializeProperties(List<Business> businesses) {
    final properties = <String, Property>{};
    for (final business in businesses) {
      properties[business.id] = Property(
        businessId: business.id,
        visitCount: 0,
      );
    }
    state = properties;
  }

  void recordVisit(String businessId) {
    if (state.containsKey(businessId)) {
      final property = state[businessId]!;
      final updated = property.copyWith(visitCount: property.visitCount + 1);
      final newState = Map<String, Property>.from(state);
      newState[businessId] = updated;
      state = newState;
    }
  }

  void claimProperty(String businessId, String playerId) {
    if (state.containsKey(businessId)) {
      final property = state[businessId]!;
      final updated = property.copyWith(
        ownerId: playerId,
        acquiredAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      );
      final newState = Map<String, Property>.from(state);
      newState[businessId] = updated;
      state = newState;
    }
  }

  void releaseProperty(String businessId) {
    if (state.containsKey(businessId)) {
      final property = state[businessId]!;
      final updated = property.copyWith(
        ownerId: null,
        acquiredAt: null,
        expiresAt: null,
      );
      final newState = Map<String, Property>.from(state);
      newState[businessId] = updated;
      state = newState;
    }
  }
}
