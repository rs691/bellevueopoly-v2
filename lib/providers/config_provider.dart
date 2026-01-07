import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_provider.dart';
// FIX: Correct imports for your file structure
import '../models/business_model.dart';
import '../services/config_service.dart';

// ConfigService singleton provider
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

// City Config provider
final cityConfigProvider = FutureProvider<CityConfig>((ref) async {
  final configService = ref.watch(configServiceProvider);
  // Ensure this matches your actual asset path
  await configService.initialize('assets/data.json');
  return configService.cityConfig;
});

// Businesses provider (ALIASES)
// We alias this to the one in business_provider or just reimplement using Firestore
final businessesProvider = FutureProvider<List<Business>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getBusinesses();
});

// Single business provider (ALIASES)
final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  final businesses = await firestoreService.getBusinesses();
  try {
     return businesses.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
});
