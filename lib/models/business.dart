class Business {
  final String id;
  final String name;
  final String? category;
  final String? heroImageUrl;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final double latitude;
  final double longitude;

  // New Fields for Rich Profile
  final String? pitch;
  final Promotion? promotion;
  final LoyaltyProgram? loyaltyProgram;

  // NEW: Add these fields to fix the errors
  final Map<String, String>? hours;
  final String? menuUrl;
  final String? secretCode;
  final int? checkInPoints;

  Business({
    required this.id,
    required this.name,
    this.category,
    this.heroImageUrl,
    this.address,
    this.phoneNumber,
    this.website,
    required this.latitude,
    required this.longitude,
    this.pitch,
    this.promotion,
    this.loyaltyProgram,
    this.hours,
    this.menuUrl,
    this.secretCode,
    this.checkInPoints,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Business',
      category: json['category'] as String? ?? 'General',
      heroImageUrl: json['heroImageUrl'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      // Use safe parsing helper or checks
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      pitch: json['pitch'] as String?,
      promotion: json['promotion'] != null && json['promotion'] is Map
          ? Promotion.fromJson(Map<String, dynamic>.from(json['promotion']))
          : null,
      loyaltyProgram: json['loyaltyProgram'] != null && json['loyaltyProgram'] is Map
          ? LoyaltyProgram.fromJson(Map<String, dynamic>.from(json['loyaltyProgram']))
          : null,
      hours: json['hours'] != null ? Map<String, String>.from(json['hours']) : null,
      menuUrl: json['menuUrl'] as String?,
      secretCode: json['secretCode'] as String? ?? 'SECRET',
      checkInPoints: _parseInt(json['checkInPoints']) ?? 100,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class Promotion {
  final String title;
  final String description;
  final String code;

  Promotion({
    required this.title,
    required this.description,
    required this.code,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String? ?? 'Special Offer',
      description: json['description'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

class LoyaltyProgram {
  final int totalCheckInsRequired;
  final int currentCheckIns;

  LoyaltyProgram({
    required this.totalCheckInsRequired,
    required this.currentCheckIns,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      totalCheckInsRequired: json['totalCheckInsRequired'] as int? ?? 10,
      currentCheckIns: json['currentCheckIns'] as int? ?? 0,
    );
  }
}
