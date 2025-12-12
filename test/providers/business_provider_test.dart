import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers/config_provider.dart';
import 'package:myapp/models/business_model.dart';
import 'package:myapp/services/config_service.dart';

// Mocking ConfigService to avoid asset loading in unit tests
class MockConfigService extends ConfigService {
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
        longitude: 0
    )
  ];

  @override
  Business? getBusinessById(String id) {
    if (id == 'mock-1') return businesses.first;
    return null;
  }
}

void main() {
  test('businessByIdProvider returns correct business from service', () async {
    // 1. Setup the container with a mocked service override
    final container = ProviderContainer(
      overrides: [
        configServiceProvider.overrideWithValue(MockConfigService()),
      ],
    );

    addTearDown(container.dispose);

    // 2. Read the provider
    // Since the provider calls initialize(), we await the future
    final businessAsync = await container.read(businessByIdProvider('mock-1').future);

    // 3. Verify state
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
