import 'package:equatable/equatable.dart';

// Supporting model for location
class BusinessLocation extends Equatable {
  final double latitude;
  final double longitude;

  const BusinessLocation({required this.latitude, required this.longitude});

  factory BusinessLocation.fromJson(Map<String, dynamic> json) {
    return BusinessLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  List<Object?> get props => [latitude, longitude];
}

// Supporting model for promotion
class BusinessPromotion extends Equatable {
  final String title;
  final String description;

  const BusinessPromotion({required this.title, required this.description});

  factory BusinessPromotion.fromJson(Map<String, dynamic> json) {
    return BusinessPromotion(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };

  @override
  List<Object?> get props => [title, description];
}

class Business extends Equatable {
  final String id;
  final String name;
  final String streetAddress;
  final String? address;
  final String city;
  final String state;
  final String zipCode;
  final String? category;
  final BusinessLocation? location;
  final String? heroImageUrl;
  final String? pitch;
  final BusinessPromotion? promotion;
  final String? website;
  final String? menuLink;
  final String? hoursOfOperation;
  final String? description;

  const Business({
    required this.id,
    required this.name,
    required this.streetAddress,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.category,
    this.location,
    this.heroImageUrl,
    this.pitch,
    this.promotion,
    this.website,
    this.menuLink,
    this.hoursOfOperation,
    this.description,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    // Extract latitude and longitude directly from the business JSON object
    final double? latitude = (json['latitude'] as num?)?.toDouble();
    final double? longitude = (json['longitude'] as num?)?.toDouble();

    BusinessLocation? businessLocation;
    if (latitude != null && longitude != null) {
      businessLocation = BusinessLocation(latitude: latitude, longitude: longitude);
    }

    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      // The 'address' field in bellevue.json seems to be a single string,
      // while your model expects streetAddress, city, state, zipCode separately.
      // I'm trying to extract them from the 'address' if present, otherwise using existing fields.
      // You might need to adjust this parsing based on the exact format of 'address'.
      streetAddress: json['address']?.split(',')[0].trim() ?? json['streetAddress'] as String,
      address: json['address'] as String?,
      city: json['address']?.split(',')[1].trim() ?? json['city'] as String,
      state: json['address']?.split(',')[2].trim().split(' ')[0].trim() ?? json['state'] as String,
      zipCode: json['address']?.split(',')[2].trim().split(' ')[1].trim() ?? json['zipCode'] as String,

      category: json['category'] as String?,
      location: businessLocation, // Use the created BusinessLocation
      heroImageUrl: json['heroImageUrl'] as String?,
      pitch: json['pitch'] as String?,
      promotion: json['promotion'] != null
          ? BusinessPromotion.fromJson(json['promotion'] as Map<String, dynamic>)
          : null,
      website: json['website'] as String?,
      // businessHours in JSON is a map, hoursOfOperation in model is a string.
      // For now, I'll join them into a string if present, or you can update the model.
      hoursOfOperation: (json['businessHours'] as Map<String, dynamic>?)?.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? json['hoursOfOperation'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'streetAddress': streetAddress,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'category': category,
    // When converting back to JSON, put latitude/longitude directly if that's the desired format
    // Or, if a nested 'location' is preferred for saving, adjust here.
    'latitude': location?.latitude,
    'longitude': location?.longitude,
    'heroImageUrl': heroImageUrl,
    'pitch': pitch,
    'promotion': promotion?.toJson(),
    'website': website,
    'menuLink': menuLink,
    'hoursOfOperation': hoursOfOperation,
    'description': description,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    streetAddress,
    city,
    state,
    zipCode,
    category,
    location,
    heroImageUrl,
    pitch,
    promotion,
    website,
    menuLink,
    hoursOfOperation,
    description,
  ];
}
