import 'package:flutter/material.dart';
import '../core/theme.dart';

class Destination {
  final String id;
  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final String description;
  final int altitudeMeters;
  final int capacityDailyTourists;
  final int currentVisitorsEst;
  final double tourismScore;
  final double waterScore;
  final double wasteScore;
  final double trafficScore;
  final double environmentScore;
  final double pressureScore;
  final String status;
  final List<String> tags;
  final List<String> popularSpots;
  final double avgDailyBudgetINR;
  final String imageUrl;
  final bool isDemo;
  final String dataSource;

  Destination({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.altitudeMeters,
    required this.capacityDailyTourists,
    required this.currentVisitorsEst,
    required this.tourismScore,
    required this.waterScore,
    required this.wasteScore,
    required this.trafficScore,
    required this.environmentScore,
    required this.pressureScore,
    required this.status,
    required this.tags,
    required this.popularSpots,
    required this.avgDailyBudgetINR,
    required this.imageUrl,
    this.isDemo = true,
    this.dataSource = "DEMO_SYNTHETIC_HACKATHON",
  });

  bool get isCritical => status.toUpperCase() == 'CRITICAL';
  bool get isHigh => status.toUpperCase() == 'HIGH';
  bool get isModerate => status.toUpperCase() == 'MODERATE';
  bool get isLow => status.toUpperCase() == 'LOW';

  Color get statusColor {
    if (isCritical) return AppColors.statusCritical;
    if (isHigh) return AppColors.statusHigh;
    if (isModerate) return AppColors.statusModerate;
    return AppColors.statusLow;
  }

  String get statusBadgeLabel {
    if (isCritical) return 'CRITICAL PRESSURE';
    if (isHigh) return 'HIGH PRESSURE';
    if (isModerate) return 'MODERATE FLOW';
    return 'RECOMMENDED (LOW PRESSURE)';
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      district: json['district'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.0,
      description: json['description'] ?? '',
      altitudeMeters: json['altitudeMeters'] ?? 2000,
      capacityDailyTourists: json['capacity'] ?? json['capacityDailyTourists'] ?? 10000,
      currentVisitorsEst: json['currentVisitorsEst'] ?? 1000,
      tourismScore: (json['tourismScore'] as num?)?.toDouble() ?? 20.0,
      waterScore: (json['waterScore'] as num?)?.toDouble() ?? 20.0,
      wasteScore: (json['wasteScore'] as num?)?.toDouble() ?? 20.0,
      trafficScore: (json['trafficScore'] as num?)?.toDouble() ?? 20.0,
      environmentScore: (json['environmentScore'] as num?)?.toDouble() ?? 20.0,
      pressureScore: (json['pressureScore'] as num?)?.toDouble() ?? 20.0,
      status: json['status'] ?? 'LOW',
      tags: List<String>.from(json['tags'] ?? []),
      popularSpots: List<String>.from(json['popularSpots'] ?? []),
      avgDailyBudgetINR: (json['avgDailyBudgetINR'] as num?)?.toDouble() ?? 2500.0,
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      isDemo: json['isDemo'] ?? true,
      dataSource: json['dataSource'] ?? "DEMO_SYNTHETIC_HACKATHON",
    );
  }
}
