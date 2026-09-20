class LocalProvider {
  final String id;
  final String destinationId;
  final String destinationName;
  final String name;
  final String category;
  final String description;
  final String ownerName;
  final String contactPhone;
  final String? contactEmail;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final double priceStartingINR;
  final String pricingUnit;
  final bool verified;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String externalBookingUrl;
  final bool isDemo;
  final String disclaimer;

  LocalProvider({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.name,
    required this.category,
    required this.description,
    required this.ownerName,
    required this.contactPhone,
    this.contactEmail,
    this.locationAddress = '',
    this.latitude = 30.0,
    this.longitude = 78.0,
    required this.priceStartingINR,
    this.pricingUnit = 'per unit',
    this.verified = true,
    required this.rating,
    this.reviewCount = 24,
    this.imageUrl = '',
    this.externalBookingUrl = '',
    this.isDemo = true,
    this.disclaimer = 'Synthetic demo provider for hackathon demonstration.',
    bool? isCertified,
  });

  bool get isCertified => verified;

  // Category helpers
  bool get isHomestay => category.toUpperCase() == 'HOMESTAY';
  bool get isGuide => category.toUpperCase() == 'LOCAL_GUIDE';
  bool get isFood => category.toUpperCase() == 'LOCAL_FOOD';
  bool get isHandicraft => category.toUpperCase() == 'HANDICRAFTS';
  bool get isLocalProduct => category.toUpperCase() == 'LOCAL_PRODUCTS';
  bool get isCulturalExperience => category.toUpperCase() == 'CULTURAL_EXPERIENCE';
  bool get isRental => category.toUpperCase() == 'RENTAL';

  /// Friendly display label for the category
  String get categoryLabel {
    switch (category.toUpperCase()) {
      case 'HOMESTAY':
        return 'Homestay';
      case 'LOCAL_GUIDE':
        return 'Local Guide';
      case 'LOCAL_FOOD':
        return 'Local Food';
      case 'HANDICRAFTS':
        return 'Handicrafts';
      case 'LOCAL_PRODUCTS':
        return 'Local Products';
      case 'CULTURAL_EXPERIENCE':
        return 'Cultural Experience';
      case 'RENTAL':
        return 'Rental';
      default:
        return category.replaceAll('_', ' ');
    }
  }

  /// Whether an external booking URL is available
  bool get hasBookingUrl =>
      externalBookingUrl.isNotEmpty &&
      (externalBookingUrl.startsWith('http://') || externalBookingUrl.startsWith('https://'));

  factory LocalProvider.fromJson(Map<String, dynamic> json) {
    return LocalProvider(
      id: json['id'] ?? '',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'HOMESTAY',
      description: json['description'] ?? '',
      ownerName: json['ownerName'] ?? 'Local Host',
      contactPhone: json['contactPhone'] ?? json['contact'] ?? '',
      contactEmail: json['contactEmail'],
      locationAddress: json['locationAddress'] ?? json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.0,
      priceStartingINR: (json['priceStartingINR'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          1500.0,
      pricingUnit: json['pricingUnit'] ?? 'per unit',
      verified: json['verified'] ?? json['isCertified'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['reviewCount'] ?? 24,
      imageUrl: json['imageUrl'] ?? '',
      externalBookingUrl: json['externalBookingUrl'] ?? '',
      isDemo: json['isDemo'] ?? true,
      disclaimer: json['disclaimer'] ?? 'Synthetic demo provider for hackathon demonstration.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'name': name,
      'category': category,
      'description': description,
      'ownerName': ownerName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'priceStartingINR': priceStartingINR,
      'pricingUnit': pricingUnit,
      'verified': verified,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'externalBookingUrl': externalBookingUrl,
      'isDemo': isDemo,
      'disclaimer': disclaimer,
    };
  }
}
