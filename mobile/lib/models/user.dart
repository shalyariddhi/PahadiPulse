class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String role; // tourist, citizen, admin
  final String? phoneNumber;
  final String photoUrl;
  final bool isBlocked;
  final String createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'tourist',
    this.phoneNumber,
    this.photoUrl = '',
    this.isBlocked = false,
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCitizen => role.toLowerCase() == 'citizen';
  bool get isTourist => role.toLowerCase() == 'tourist';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Pahadi Traveler',
      role: json['role'] ?? 'tourist',
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'] ?? '',
      isBlocked: json['isBlocked'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'role': role,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'isBlocked': isBlocked,
    'createdAt': createdAt,
  };
}
