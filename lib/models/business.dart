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
  });
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
}

class LoyaltyProgram {
  final int totalCheckInsRequired;
  final int currentCheckIns; // In a real app, this would be user-specific

  LoyaltyProgram({
    required this.totalCheckInsRequired,
    required this.currentCheckIns,
  });
}
