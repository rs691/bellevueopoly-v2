import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Businesses provider
final businessesProvider = FutureProvider<List<Business>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  await configService.initialize('assets/data.json');
  return configService.businesses;
});

// Single business provider
final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final configService = ref.watch(configServiceProvider);
  await configService.initialize('assets/data.json');
  return configService.getBusinessById(id);
});
