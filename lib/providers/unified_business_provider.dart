import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_model.dart';
import 'firestore_business_provider.dart';
import 'config_provider.dart';

/// Unified business list: uses Firestore, falls back to ConfigService JSON on error/empty
final unifiedBusinessesProvider = StreamProvider<List<Business>>((ref) async* {
  final configService = ref.read(configServiceProvider);

  final businesses = ref.watch(firestoreBusinessesProvider);
  yield businesses.when(
    data: (list) => list.isNotEmpty ? list : configService.businesses,
    loading: () => configService.businesses, // Show JSON during initial load
    error: (_, __) => configService.businesses, // Fallback on Firestore errors
  );
});

/// Unified business by ID: uses Firestore, falls back to ConfigService
final unifiedBusinessByIdProvider = StreamProvider.family<Business?, String>((
  ref,
  id,
) async* {
  final configService = ref.read(configServiceProvider);

  final business = ref.watch(firestoreBusinessByIdProvider(id));
  yield business.when(
    data: (b) => b ?? configService.getBusinessById(id),
    loading: () => configService.getBusinessById(id),
    error: (_, __) => configService.getBusinessById(id),
  );
});
