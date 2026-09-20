class NotificationItem {
  final String id;
  final String? userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final String createdAt;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? targetRole;
  final Map<String, dynamic> metadata;

  NotificationItem({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.createdAt,
    this.relatedEntityId,
    this.relatedEntityType,
    this.targetRole,
    this.metadata = const {},
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      title: json['title']?.toString() ?? 'PahadiPulse Alert',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL_ANNOUNCEMENT',
      read: json['read'] == true,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      relatedEntityType: json['relatedEntityType']?.toString(),
      targetRole: json['targetRole']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'createdAt': createdAt,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'targetRole': targetRole,
      'metadata': metadata,
    };
  }

  NotificationItem copyWith({
    bool? read,
  }) {
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      targetRole: targetRole,
      metadata: metadata,
    );
  }
}
