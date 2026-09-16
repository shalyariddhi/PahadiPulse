class LocalProvider {
  final String id;
  final String destinationId;
  final String destinationName;
  final String name;
  final String category;
  final String description;
  final String ownerName;
  final String contactPhone;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final double priceStartingINR;
  final String pricingUnit;
  final bool verified;
  final double rating;
  final int reviewCount;
  final String imageUrl;

  LocalProvider({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.name,
    required this.category,
    required this.description,
    required this.ownerName,
    required this.contactPhone,
    this.locationAddress = '',
    this.latitude = 30.0,
    this.longitude = 78.0,
    required this.priceStartingINR,
    this.pricingUnit = 'per night',
    this.verified = true,
    required this.rating,
    this.reviewCount = 24,
    this.imageUrl = '',
    bool? isCertified,
  });

  bool get isCertified => verified;

  factory LocalProvider.fromJson(Map<String, dynamic> json) {
    return LocalProvider(
      id: json['id'] ?? '',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'HOMESTAY',
      description: json['description'] ?? '',
      ownerName: json['ownerName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.0,
      priceStartingINR: (json['priceStartingINR'] as num?)?.toDouble() ?? 1500.0,
      pricingUnit: json['pricingUnit'] ?? 'per night',
      verified: json['verified'] ?? json['isCertified'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['reviewCount'] ?? 24,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
