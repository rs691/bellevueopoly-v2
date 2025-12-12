import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// CHANGE 'belle_opoly' to your actual package name
import '../../lib/providers/config_provider.dart';
import 'package:belle_opoly/models/business_model.dart';
import 'package:belle_opoly/services/config_service.dart';

// Using 'implements' avoids issues with ConfigService's private constructor
class MockConfigService implements ConfigService {
  @override
  Future<void> initialize(String configPath) async {
    return; // No-op
  }

  @override
  List<Business> get businesses => [
    Business(
        id: 'mock-1',
        name: 'Mock Biz',
        category: 'Test',
        latitude: 0,
        longitude: 0,
        address: 'Test Addr'
    )
  ];

  @override
  Business? getBusinessById(String id) {
    if (id == 'mock-1') return businesses.first;
    return null;
  }

  // Satisfy other interface requirements if necessary (e.g. cityConfig)
  @override
  CityConfig get cityConfig => CityConfig(name: 'Test City', state: 'TS', zipCode: '00000');
}

void main() {
  test('businessByIdProvider returns correct business from service', () async {
    final container = ProviderContainer(
      overrides: [
        configServiceProvider.overrideWithValue(MockConfigService()),
      ],
    );
    addTearDown(container.dispose);

    final businessAsync = await container.read(businessByIdProvider('mock-1').future);

    expect(businessAsync, isNotNull);
    expect(businessAsync!.name, 'Mock Biz');
  });

  test('businessByIdProvider returns null for invalid ID', () async {
    final container = ProviderContainer(
      overrides: [
        configServiceProvider.overrideWithValue(MockConfigService()),
      ],
    );
    addTearDown(container.dispose);

    final businessAsync = await container.read(businessByIdProvider('invalid-id').future);

    expect(businessAsync, isNull);
  });
}
