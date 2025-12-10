import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/models/business.dart'; // Added import for the correct Business model
// import '../models/index.dart'; // Removed old import

// Assuming Property class is defined elsewhere or will be created later
// For now, let's assume a simple Property class definition for compilation.
// If this causes an error, you'll need to provide the actual definition of Property.
class Property {
  final String businessId;
  final int visitCount;
  final String? ownerId;
  final DateTime? acquiredAt;
  final DateTime? expiresAt;

  const Property({
    required this.businessId,
    this.visitCount = 0,
    this.ownerId,
    this.acquiredAt,
    this.expiresAt,
  });

  Property copyWith({
    String? businessId,
    int? visitCount,
    String? ownerId,
    DateTime? acquiredAt,
    DateTime? expiresAt,
  }) {
    return Property(
      businessId: businessId ?? this.businessId,
      visitCount: visitCount ?? this.visitCount,
      ownerId: ownerId,
      acquiredAt: acquiredAt,
      expiresAt: expiresAt,
    );
  }
}

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
