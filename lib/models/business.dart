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
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'General',
      heroImageUrl: json['heroImageUrl'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      pitch: json['pitch'] as String?,
      promotion: json['promotion'] != null
          ? Promotion.fromJson(json['promotion'] as Map<String, dynamic>)
          : null,
      loyaltyProgram: json['loyaltyProgram'] != null
          ? LoyaltyProgram.fromJson(json['loyaltyProgram'] as Map<String, dynamic>)
          : null,
      // NEW: Parse the new fields
      hours: json['hours'] != null ? Map<String, String>.from(json['hours']) : null,
      menuUrl: json['menuUrl'] as String?,
    );
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
      title: json['title'] as String,
      description: json['description'] as String,
      code: json['code'] as String,
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
