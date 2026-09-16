import 'package:flutter_test/flutter_test.dart';
import 'package:pahadipulse/models/destination.dart';
import 'package:pahadipulse/models/prediction.dart';
import 'package:pahadipulse/models/report.dart';
import 'package:pahadipulse/models/provider.dart';
import 'package:pahadipulse/providers/app_state.dart';

void main() {
  group('PahadiPulse Mobile Data Models & Deserialization', () {
    test('Destination JSON parsing and pressure classification', () {
      final json = {
        'id': 'kanatal',
        'name': 'Kanatal',
        'district': 'Tehri Garhwal',
        'latitude': 30.4180,
        'longitude': 78.3444,
        'description': 'Pristine mountain ridge',
        'altitudeMeters': 2590,
        'capacityDailyTourists': 4000,
        'currentVisitorsEst': 950,
        'tourismScore': 18.0,
        'waterScore': 25.0,
        'wasteScore': 15.0,
        'trafficScore': 12.0,
        'environmentScore': 20.0,
        'pressureScore': 18.4,
        'status': 'LOW',
        'tags': ['Nature', 'Peace'],
        'popularSpots': ['Surkanda Devi Temple'],
        'avgDailyBudgetINR': 2200,
      };

      final dest = Destination.fromJson(json);
      expect(dest.id, 'kanatal');
      expect(dest.name, 'Kanatal');
      expect(dest.pressureScore, 18.4);
      expect(dest.status, 'LOW');
      expect(dest.isLow, true);
    });

    test('DestinationPrediction JSON parsing', () {
      final json = {
        'destination_id': 'mussoorie',
        'destination_name': 'Mussoorie',
        'current_score': 80.4,
        'predicted_score': 84.2,
        'prediction_horizon_days': 3,
        'target_date': '2026-09-17',
        'risk_level': 'CRITICAL',
        'model_confidence': 0.94,
        'conf_lower': 78.0,
        'conf_upper': 90.0,
        'algorithm': 'GradientBoostingRegressor',
        'primary_risk_factor': 'Weekend Tourist Influx',
        'is_demo': false,
        'disclaimer': 'Forecasted telemetry',
      };

      final pred = DestinationPrediction.fromJson(json);
      expect(pred.destinationId, 'mussoorie');
      expect(pred.predictedScore, 84.2);
      expect(pred.riskLevel, 'CRITICAL');
      expect(pred.modelConfidence, 0.94);
    });

    test('Report and LocalProvider models work as expected', () {
      final report = Report(
        id: 'rep_101',
        userId: 'u_123',
        userName: 'Pahadi Tourist',
        destinationId: 'nainital',
        destinationName: 'Nainital',
        category: 'TRAFFIC',
        description: 'Heavy parking jam near Mallital',
        imageUrl: '',
        latitude: 29.3803,
        longitude: 79.4636,
        aiCategory: 'TRAFFIC',
        aiSeverity: 4,
        aiConfidence: 0.95,
        aiExplanation: 'Transit barrier',
        status: 'AI_CLASSIFIED',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(report.destinationName, 'Nainital');
      expect(report.aiSeverity, 4);

      final provider = LocalProvider(
        id: 'p_1',
        name: 'Himalayan Homestay',
        category: 'HOMESTAY',
        destinationId: 'kanatal',
        destinationName: 'Kanatal',
        ownerName: 'Sunita Devi',
        contactPhone: '+91 9876543210',
        rating: 4.9,
        reviewCount: 42,
        priceStartingINR: 1800,
        description: 'Eco-lodge in village',
        verified: true,
      );

      expect(provider.isCertified, true);
      expect(provider.rating, 4.9);
      expect(provider.reviewCount, 42);
    });

    test('AppState bookmark toggle and search filtering', () {
      final appState = AppState();
      expect(appState.savedDestinationIds.length, 2);

      appState.toggleSaveDestination('auli');
      expect(appState.isDestinationSaved('auli'), true);

      appState.toggleSaveDestination('auli');
      expect(appState.isDestinationSaved('auli'), false);
    });
  });
}
