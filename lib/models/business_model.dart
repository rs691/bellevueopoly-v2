import 'business.dart';

class Business {
  final String id;
  final String name;
  final String category;
  final String? heroImageUrl;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final double latitude;
  final double longitude;
  final String? pitch;
  final Promotion? promotion;
  final LoyaltyProgram? loyaltyProgram;

  // NEW FIELDS
  final Map<String, String>? hours; // e.g., {"Mon-Fri": "9am-5pm"}
  final String? menuUrl;
  final String? secretCode;
  final int? checkInPoints;

  Business({
    required this.id,
    required this.name,
    required this.category,
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
      // PARSE NEW FIELDS
      hours: json['hours'] != null ? Map<String, String>.from(json['hours']) : null,
      menuUrl: json['menuUrl'] as String?,
      secretCode: json['secretCode'] as String? ?? 'SECRET',
      checkInPoints: json['checkInPoints'] as int? ?? 100,
    );
  }
}
// ... Promotion and LoyaltyProgram classes remain the same
