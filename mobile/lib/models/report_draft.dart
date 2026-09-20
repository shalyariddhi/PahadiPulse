class ReportDraft {
  final String id;
  final String destinationId;
  final String destinationName;
  final String description;
  final String category;
  final int userSeverity;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? localPhotoPath;
  final String createdAt;
  final String syncStatus; // 'PENDING', 'SYNCING', 'FAILED'

  ReportDraft({
    required this.id,
    required this.destinationId,
    this.destinationName = '',
    required this.description,
    this.category = 'OTHER',
    this.userSeverity = 3,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.localPhotoPath,
    required this.createdAt,
    this.syncStatus = 'PENDING',
  });

  factory ReportDraft.fromJson(Map<String, dynamic> json) {
    return ReportDraft(
      id: json['id']?.toString() ?? '',
      destinationId: json['destinationId']?.toString() ?? '',
      destinationName: json['destinationName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'OTHER',
      userSeverity: (json['userSeverity'] as num?)?.toInt() ?? 3,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.5,
      imageUrl: json['imageUrl']?.toString(),
      localPhotoPath: json['localPhotoPath']?.toString(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      syncStatus: json['syncStatus']?.toString() ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'description': description,
      'category': category,
      'userSeverity': userSeverity,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'localPhotoPath': localPhotoPath,
      'createdAt': createdAt,
      'syncStatus': syncStatus,
    };
  }

  ReportDraft copyWith({
    String? syncStatus,
    String? imageUrl,
  }) {
    return ReportDraft(
      id: id,
      destinationId: destinationId,
      destinationName: destinationName,
      description: description,
      category: category,
      userSeverity: userSeverity,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      localPhotoPath: localPhotoPath,
      createdAt: createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
