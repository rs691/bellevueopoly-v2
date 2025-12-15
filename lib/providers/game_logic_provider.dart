import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'business_provider.dart';
import 'location_provider.dart';
import 'auth_provider.dart';
import 'package:flutter/material.dart';

// Provider to hold the GameController logic
final gameControllerProvider = Provider<GameController>((ref) {
  return GameController(ref);
});

class GameController {
  final Ref _ref;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Cooldown map: StoreID -> Last Visit Time
  // Prevents spamming points for the same store
  final Map<String, DateTime> _cooldowns = {};
  
  // Minimum time between visits to the same store
  static const Duration _cooldownDuration = Duration(minutes: 5);
  
  // Distance threshold in meters (approx 100 feet)
  static const double _visitThreshold = 30.48; 

  GameController(this._ref);

  // Called when the Game Screen initializes to start listening
  void startGameLoop(BuildContext context) {
    // Listen to location updates
    _ref.listen<AsyncValue<Position?>>(userLocationProvider, (previous, next) {
      next.whenData((position) {
        if (position != null) {
          _checkProximity(context, position);
        }
      });
    });
  }

  void _checkProximity(BuildContext context, Position userPos) {
    // Get the list of businesses
    final businessesAsync = _ref.read(businessListProvider);
    
    businessesAsync.whenData((businesses) {
      for (var business in businesses) {
        if (business.latitude != 0.0 && business.longitude != 0.0) {
          
          final double distance = Geolocator.distanceBetween(
            userPos.latitude,
            userPos.longitude,
            business.latitude,
            business.longitude,
          );

          if (distance <= _visitThreshold) {
            _triggerVisit(context, business);
          }
        }
      }
    });
  }

  Future<void> _triggerVisit(BuildContext context, Business business) async {
    final now = DateTime.now();
    final lastVisit = _cooldowns[business.id];

    // Check cooldown
    if (lastVisit != null && now.difference(lastVisit) < _cooldownDuration) {
      return; // Too soon
    }

    // Update cooldown
    _cooldowns[business.id] = now;

    // Get current user
    final userAsync = _ref.read(authStateProvider);
    final user = userAsync.value;

    if (user != null) {
      // 1. Add Points
      await _firestoreService.addPoints(user.uid, 10);

      // 2. Show Notification (if context is valid)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You visited ${business.name} and earned 10 points!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
