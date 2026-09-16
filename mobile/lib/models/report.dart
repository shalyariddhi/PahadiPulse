class Report {
  final String id;
  final String userId;
  final String userName;
  final String destinationId;
  final String destinationName;
  final String category;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String aiCategory;
  final int aiSeverity;
  final double aiConfidence;
  final String aiExplanation;
  final String status;
  final String? adminNotes;
  final String createdAt;

  Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.destinationId,
    required this.destinationName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.aiCategory,
    required this.aiSeverity,
    required this.aiConfidence,
    required this.aiExplanation,
    required this.status,
    this.adminNotes,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Pahadi Citizen',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      category: json['category'] ?? 'OTHER',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.0,
      aiCategory: json['aiCategory'] ?? 'OTHER',
      aiSeverity: json['aiSeverity'] ?? 3,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble() ?? 0.8,
      aiExplanation: json['aiExplanation'] ?? '',
      status: json['status'] ?? 'SUBMITTED',
      adminNotes: json['adminNotes'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
