import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../assets/data/config.json';
import 'package:myapp/models/business_model.dart';
import 'package:myapp/services/config_service.dart';

void main() {
  group('Data Extraction & Parsing Tests', () {
    // Simulated content of assets/config/bellevue.json
    const mockJsonData = '''
    {
      "city_config": {
        "name": "Bellevue",
        "state": "NE",
        "zip_code": "68005"
      },
      "businesses": [
        {
          "id": "test-business-1",
          "name": "Test Cafe",
          "category": "Restaurant",
          "address": "123 Main St",
          "latitude": 41.15,
          "longitude": -95.92,
          "heroImageUrl": "http://example.com/image.jpg",
          "promotion": {
            "title": "Free Coffee",
            "description": "Buy one get one",
            "code": "BOGO"
          }
        }
      ]
    }
    ''';

    test('CityConfig should parse correctly from JSON', () {
      final Map<String, dynamic> jsonMap = jsonDecode(mockJsonData);
      final cityConfig = CityConfig.fromJson(jsonMap);

      expect(cityConfig.name, 'Bellevue', reason: 'City Name should match JSON');
      expect(cityConfig.state, 'NE', reason: 'State should match JSON');
      expect(cityConfig.zipCode, '68005', reason: 'Zip should match JSON');
    });

    test('Business Model should parse correctly including nested objects', () {
      final Map<String, dynamic> jsonMap = jsonDecode(mockJsonData);
      final List<dynamic> businessList = jsonMap['businesses'];

      final business = Business.fromJson(businessList[0]);

      expect(business.id, 'test-business-1');
      expect(business.name, 'Test Cafe');
      expect(business.latitude, 41.15);

      // Verify "Rich Profile" data
      expect(business.promotion, isNotNull);
      expect(business.promotion!.code, 'BOGO');
    });

    test('Business Model should handle missing optional fields safely', () {
      const minimalJson = '''
      {
        "id": "minimal-biz",
        "name": "Minimalist Inc",
        "category": "Services",
        "latitude": 0.0,
        "longitude": 0.0
      }
      ''';

      final business = Business.fromJson(jsonDecode(minimalJson));

      expect(business.name, 'Minimalist Inc');
      expect(business.promotion, isNull);
      expect(business.heroImageUrl, isNull);
      expect(business.category, 'Services');
    });
  });
}
