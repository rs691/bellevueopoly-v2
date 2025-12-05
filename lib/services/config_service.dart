import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/index.dart';

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

      final businessesJson = jsonData['businesses'] as List<dynamic>;
      _businesses = businessesJson
          .map((b) => Business.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load config from $configPath: $e');
    }
  }

  CityConfig get cityConfig {
    if (_cityConfig == null) {
      throw Exception(
        'ConfigService not initialized. Call initialize() first.',
      );
    }
    return _cityConfig!;
  }

  List<Business> get businesses {
    if (_businesses == null) {
      throw Exception(
        'ConfigService not initialized. Call initialize() first.',
      );
    }
    return _businesses!;
  }

  Business? getBusinessById(String id) {
    if (_businesses == null) return null;
    try {
      return _businesses!.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
