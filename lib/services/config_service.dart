import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/business_model.dart'; // Fixed import name

// Assuming you have a city_model.dart, otherwise creates a basic placeholder
class CityConfig {
  final String name;
  CityConfig({required this.name});
  factory CityConfig.fromJson(Map<String, dynamic> json) {
    // robust parsing for nested 'city_config' or direct properties
    final data = json['city_config'] ?? json;
    return CityConfig(name: data['name'] ?? 'Unknown City');
  }
}

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  CityConfig? _cityConfig;
  List<Business>? _businesses;

  Future<void> initialize(String configPath) async {
    try {
      final jsonString = await rootBundle.loadString(configPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      _cityConfig = CityConfig.fromJson(jsonData);

      final businessesJson = jsonData['businesses'] as List<dynamic>?;

      _businesses = [];
      if (businessesJson != null) {
        for (var b in businessesJson) {
          try {
            _businesses!.add(Business.fromJson(b as Map<String, dynamic>));
          } catch (e) {
            // Log error for specific business but continue loading others
            print('Skipping invalid business entry: $e');
          }
        }
      }
    } catch (e) {
      print('CRITICAL: Failed to load config from $configPath: $e');
      // Initialize with empty defaults to prevent app crash
      _businesses = [];
      _cityConfig = CityConfig(name: "Error Loading Config");
    }
  }

  CityConfig get cityConfig => _cityConfig!;

  List<Business> get businesses => _businesses ?? [];

  Business? getBusinessById(String id) {
    if (_businesses == null) return null;
    try {
      return _businesses!.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
