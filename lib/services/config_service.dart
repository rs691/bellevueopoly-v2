import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/business_model.dart';

class CityConfig {
  final String name;
  final String state;
  final String zipCode;

  CityConfig({
    required this.name,
    required this.state,
    required this.zipCode,
  });

  factory CityConfig.fromJson(Map<String, dynamic> json) {
    // Robust parsing: checks for nested 'city_config' or uses defaults
    final data = json['city_config'] ?? json;
    return CityConfig(
      name: data['name'] ?? 'Bellevue', // Default fallback
      state: data['state'] ?? 'NE',
      zipCode: data['zip_code'] ?? '68005',
    );
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
      // Change: Decode as dynamic to handle List or Map
      final dynamic jsonData = jsonDecode(jsonString);

      _businesses = [];

      if (jsonData is Map<String, dynamic>) {
        // Format A: Object with "city_config" and "businesses" keys
        _cityConfig = CityConfig.fromJson(jsonData);
        final list = jsonData['businesses'] as List<dynamic>?;
        if (list != null) {
          _parseBusinesses(list);
        }
      } else if (jsonData is List<dynamic>) {
        // Format B: Just a raw list of businesses (matches your current file)
        // Use default City Config since it's missing from the file
        _cityConfig = CityConfig(name: 'Bellevue', state: 'NE', zipCode: '68005');
        _parseBusinesses(jsonData);
      } else {
        debugPrint('CRITICAL: Unknown JSON format in $configPath');
      }

    } catch (e) {
      debugPrint('CRITICAL: Failed to load config from $configPath: $e');
      _businesses = [];
      _cityConfig = CityConfig(name: "Error", state: "", zipCode: "");
    }
  }

  // Helper to parse the list safely
  void _parseBusinesses(List<dynamic> list) {
    for (var b in list) {
      try {
        _businesses!.add(Business.fromJson(b as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipping invalid business entry: $e');
      }
    }
  }

  CityConfig get cityConfig => _cityConfig ?? CityConfig(name: "Loading...", state: "", zipCode: "");

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
