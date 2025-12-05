import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/index.dart';
import '../services/index.dart';

// ConfigService singleton provider
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

// City Config provider - loads once
final cityConfigProvider = FutureProvider<CityConfig>((ref) async {
  final configService = ref.watch(configServiceProvider);
  await configService.initialize('assets/config/bellevue.json');
  return configService.cityConfig;
});

// Businesses provider - loads once
final businessesProvider = FutureProvider<List<Business>>((ref) async {
  final configService = ref.watch(configServiceProvider);
  await configService.initialize('assets/config/bellevue.json');
  return configService.businesses;
});

// Single business provider
final businessByIdProvider = FutureProvider.family<Business?, String>((
  ref,
  id,
) async {
  final configService = ref.watch(configServiceProvider);
  await configService.initialize('assets/config/bellevue.json');
  return configService.getBusinessById(id);
});
