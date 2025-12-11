import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import '../services/config_service.dart';

// Provider to get all businesses from the loaded ConfigService
final businessListProvider = FutureProvider<List<Business>>((ref) async {
  // We assume ConfigService.initialize() is called in main.dart
  // If not, we could lazily await it here, but typically main.dart handles init.
  final configService = ConfigService();

  // Return the list (it might be empty if init failed, but won't crash)
  return configService.businesses;
});

// Provider to get a single business by ID
final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final configService = ConfigService();
  return configService.getBusinessById(id);
});
