import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  List<Object?> get props => [latitude, longitude];
}

class Promotion extends Equatable {
  final String title;
  final String description;
  final String discount;
  final String expiresAt;

  const Promotion({
    required this.title,
    required this.description,
    required this.discount,
    required this.expiresAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String,
      description: json['description'] as String,
      discount: json['discount'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'discount': discount,
    'expiresAt': expiresAt,
  };

  @override
  List<Object?> get props => [title, description, discount, expiresAt];
}

class LoyaltyTier extends Equatable {
  final int visitsRequired;
  final String rewardDescription;

  const LoyaltyTier({
    required this.visitsRequired,
    required this.rewardDescription,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      visitsRequired: json['visitsRequired'] as int,
      rewardDescription: json['rewardDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'visitsRequired': visitsRequired,
    'rewardDescription': rewardDescription,
  };

  @override
  List<Object?> get props => [visitsRequired, rewardDescription];
}

class Business extends Equatable {
  final String id;
  final String name;
  final String category;
  final LatLng location;
  final String description;
  final String pitch;
  final String heroImageUrl;
  final String address;
  final String phoneNumber;
  final String website;
  final Map<String, String> businessHours;
  final bool isOpen;
  final Promotion promotion;
  final LoyaltyTier loyaltyTier;

  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.pitch,
    required this.heroImageUrl,
    required this.address,
    required this.phoneNumber,
    required this.website,
    required this.businessHours,
    required this.isOpen,
    required this.promotion,
    required this.loyaltyTier,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      location: LatLng(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
      ),
      description: json['description'] as String,
      pitch: json['pitch'] as String,
      heroImageUrl: json['heroImageUrl'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      website: json['website'] as String,
      businessHours: Map<String, String>.from(
        json['businessHours'] as Map<String, dynamic>,
      ),
      isOpen: json['isOpen'] as bool,
      promotion: Promotion.fromJson(json['promotion'] as Map<String, dynamic>),
      loyaltyTier: LoyaltyTier.fromJson(
        json['loyaltyTier'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'latitude': location.latitude,
    'longitude': location.longitude,
    'description': description,
    'pitch': pitch,
    'heroImageUrl': heroImageUrl,
    'address': address,
    'phoneNumber': phoneNumber,
    'website': website,
    'businessHours': businessHours,
    'isOpen': isOpen,
    'promotion': promotion.toJson(),
    'loyaltyTier': loyaltyTier.toJson(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    location,
    description,
    pitch,
    heroImageUrl,
    address,
    phoneNumber,
    website,
    businessHours,
    isOpen,
    promotion,
    loyaltyTier,
  ];
}
