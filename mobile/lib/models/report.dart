import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

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
  final int? userSeverity;
  final String aiCategory;
  final int aiSeverity;
  final double aiConfidence;
  final String aiExplanation;
  final String status;
  final String? adminNotes;
  final String createdAt;
  final String? resolvedAt;

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
    this.userSeverity,
    required this.aiCategory,
    required this.aiSeverity,
    required this.aiConfidence,
    required this.aiExplanation,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.resolvedAt,
  });

  int get workflowStageIndex {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 0;
      case 'AI_CLASSIFIED':
        return 1;
      case 'VERIFIED':
        return 2;
      case 'ASSIGNED':
        return 3;
      case 'RESOLVED':
        return 4;
      default:
        return 1;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return AppColors.statusLow;
      case 'ASSIGNED':
        return AppColors.forestAccent;
      case 'VERIFIED':
        return AppColors.pineTeal;
      case 'AI_CLASSIFIED':
        return const Color(0xFF38BDF8);
      case 'SUBMITTED':
      default:
        return AppColors.statusModerate;
    }
  }

  String get statusDisplayLabel {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 'Submitted';
      case 'AI_CLASSIFIED':
        return 'AI Classified';
      case 'VERIFIED':
        return 'Verified';
      case 'ASSIGNED':
        return 'Assigned to Dept';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  IconData get categoryIcon {
    switch (category.toUpperCase()) {
      case 'WATER':
        return LucideIcons.droplets;
      case 'WASTE':
        return LucideIcons.trash2;
      case 'ROAD':
        return LucideIcons.truck;
      case 'TRAFFIC':
        return LucideIcons.car;
      case 'HEALTH':
        return LucideIcons.activity;
      case 'CONNECTIVITY':
        return LucideIcons.wifi;
      case 'TOURISM':
        return LucideIcons.compass;
      case 'ENVIRONMENT':
        return LucideIcons.trees;
      case 'OTHER':
      default:
        return LucideIcons.alertTriangle;
    }
  }

  Color get categoryColor {
    switch (category.toUpperCase()) {
      case 'WATER':
        return const Color(0xFF38BDF8);
      case 'WASTE':
        return const Color(0xFFF97316);
      case 'ROAD':
        return const Color(0xFFEF4444);
      case 'TRAFFIC':
        return const Color(0xFFFBBF24);
      case 'HEALTH':
        return const Color(0xFFEC4899);
      case 'CONNECTIVITY':
        return const Color(0xFF8B5CF6);
      case 'TOURISM':
        return const Color(0xFF10B981);
      case 'ENVIRONMENT':
        return const Color(0xFF22C55E);
      case 'OTHER':
      default:
        return const Color(0xFF94A3B8);
    }
  }

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
      userSeverity: (json['userSeverity'] as num?)?.toInt(),
      aiCategory: json['aiCategory'] ?? 'OTHER',
      aiSeverity: (json['aiSeverity'] as num?)?.toInt() ?? 3,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble() ?? 0.85,
      aiExplanation: json['aiExplanation'] ?? '',
      status: json['status'] ?? 'AI_CLASSIFIED',
      adminNotes: json['adminNotes'],
      createdAt: json['createdAt'] ?? '',
      resolvedAt: json['resolvedAt'],
    );
  }
}

