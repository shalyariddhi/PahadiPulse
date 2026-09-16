import 'package:flutter/material.dart';
import '../core/theme.dart';

class DestinationPrediction {
  final String destinationId;
  final String destinationName;
  final double currentScore;
  final double predictedScore;
  final int predictionHorizonDays;
  final String targetDate;
  final String riskLevel;
  final double modelConfidence;
  final double confLower;
  final double confUpper;
  final String algorithm;
  final String primaryRiskFactor;
  final bool isDemo;
  final String disclaimer;

  DestinationPrediction({
    required this.destinationId,
    required this.destinationName,
    required this.currentScore,
    required this.predictedScore,
    required this.predictionHorizonDays,
    required this.targetDate,
    required this.riskLevel,
    required this.modelConfidence,
    required this.confLower,
    required this.confUpper,
    required this.algorithm,
    required this.primaryRiskFactor,
    required this.isDemo,
    required this.disclaimer,
  });

  Color get riskColor {
    final r = riskLevel.toUpperCase();
    if (r == 'CRITICAL') return AppColors.statusCritical;
    if (r == 'HIGH') return AppColors.statusHigh;
    if (r == 'MODERATE') return AppColors.statusModerate;
    return AppColors.statusLow;
  }

  factory DestinationPrediction.fromJson(Map<String, dynamic> json) {
    final confRange = json['confidenceRange'] as Map<String, dynamic>? ?? json['confidence_range'] as Map<String, dynamic>? ?? {};
    final modelDetails = json['modelDetails'] as Map<String, dynamic>? ?? json['model_details'] as Map<String, dynamic>? ?? {};

    return DestinationPrediction(
      destinationId: json['destinationId'] ?? json['destination_id'] ?? '',
      destinationName: json['destinationName'] ?? json['destination_name'] ?? '',
      currentScore: (json['currentScore'] as num?)?.toDouble() ?? (json['current_score'] as num?)?.toDouble() ?? 30.0,
      predictedScore: (json['predictedScore'] as num?)?.toDouble() ?? (json['predicted_score'] as num?)?.toDouble() ?? 35.0,
      predictionHorizonDays: json['predictionHorizonDays'] ?? json['prediction_horizon_days'] ?? 3,
      targetDate: json['targetDate'] ?? json['target_date'] ?? '',
      riskLevel: json['riskLevel'] ?? json['risk_level'] ?? 'LOW',
      modelConfidence: (json['modelConfidence'] as num?)?.toDouble() ?? (json['model_confidence'] as num?)?.toDouble() ?? 0.95,
      confLower: (confRange['lower'] as num?)?.toDouble() ?? (json['conf_lower'] as num?)?.toDouble() ?? 30.0,
      confUpper: (confRange['upper'] as num?)?.toDouble() ?? (json['conf_upper'] as num?)?.toDouble() ?? 40.0,
      algorithm: modelDetails['algorithm'] ?? json['algorithm'] ?? 'GradientBoostingRegressor',
      primaryRiskFactor: json['primaryRiskFactor'] ?? json['primary_risk_factor'] ?? 'Tourism Density',
      isDemo: json['isDemo'] ?? json['is_demo'] ?? true,
      disclaimer: json['disclaimer'] ?? 'Synthetic prediction demo for IBM Hackathon.',
    );
  }
}
