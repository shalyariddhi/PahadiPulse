import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pahadipulse/models/destination.dart';
import 'package:pahadipulse/models/prediction.dart';
import 'package:pahadipulse/models/report.dart';
import 'package:pahadipulse/models/provider.dart' as model;
import 'package:pahadipulse/models/notification.dart';
import 'package:pahadipulse/models/itinerary.dart';
import 'package:pahadipulse/providers/app_state.dart';
import 'package:pahadipulse/views/home/home_screen.dart';
import 'package:pahadipulse/views/auth/login_screen.dart';

import 'package:pahadipulse/services/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    ConnectivityService().stopMonitoring();
  });

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
        imageUrl: 'https://example.com/traffic.jpg',
        latitude: 29.3803,
        longitude: 79.4636,
        userSeverity: 4,
        aiCategory: 'TRAFFIC',
        aiSeverity: 4,
        aiConfidence: 0.95,
        aiExplanation: 'Transit barrier',
        status: 'AI_CLASSIFIED',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(report.destinationName, 'Nainital');
      expect(report.aiSeverity, 4);
      expect(report.userSeverity, 4);
      expect(report.workflowStageIndex, 1);
      expect(report.statusDisplayLabel, 'AI Classified');

      final resolvedReport = Report(
        id: 'rep_102',
        userId: 'u_123',
        userName: 'Citizen',
        destinationId: 'kanatal',
        destinationName: 'Kanatal',
        category: 'WATER',
        description: 'Water leak fixed',
        imageUrl: '',
        latitude: 30.41,
        longitude: 78.34,
        aiCategory: 'WATER',
        aiSeverity: 2,
        aiConfidence: 0.9,
        aiExplanation: 'Water leak',
        status: 'RESOLVED',
        createdAt: DateTime.now().toIso8601String(),
      );
      expect(resolvedReport.workflowStageIndex, 4);
      expect(resolvedReport.statusDisplayLabel, 'Resolved');

      final provider = model.LocalProvider(
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

    test('GeneratedItinerary and Day calculation serialization', () {
      final itin = GeneratedItinerary(
        id: 'itin_test_01',
        title: 'Chopta Trek Circuit',
        daysCount: 3,
        travellersCount: 2,
        budgetPerPersonINR: 8000,
        totalEstimatedCostINR: 14500,
        pressureMitigationScore: 78.5,
        interests: ['Trekking', 'Nature'],
        startingRegion: 'Rishikesh',
        rationale: 'Avoids congested hubs',
        days: [
          ItineraryDay(
            dayNumber: 1,
            destinationId: 'chopta',
            destinationName: 'Chopta',
            district: 'Rudraprayag',
            pressureLevel: 'LOW',
            pressureScore: 22.0,
            stayRecommendation: ItineraryStay(
              name: 'Alpine Meadows Camp',
              type: 'Eco Camp',
              costPerNightINR: 1500,
            ),
            activities: [
              ItineraryActivity(
                time: '10:00 AM',
                title: 'Tungnath Trek',
                description: 'Ascent to world highest Shiva temple',
                category: 'Trekking',
                costEstimateINR: 500,
              ),
            ],
            travelNote: 'Scenic mountain drive',
          )
        ],
      );

      final jsonMap = itin.toJson();
      expect(jsonMap['id'], 'itin_test_01');
      expect(jsonMap['daysCount'], 3);
      expect(jsonMap['days'].length, 1);
    });

    test('AppState bookmark toggle, search, and low-connectivity simulation', () {
      final appState = AppState();
      expect(appState.isDestinationSaved('auli'), false);

      appState.toggleSaveDestination('auli');
      expect(appState.isDestinationSaved('auli'), true);

      appState.toggleSaveDestination('auli');
      expect(appState.isDestinationSaved('auli'), false);

      // Simulated offline toggle
      expect(appState.isSimulatedOffline, false);
      appState.toggleSimulatedOffline();
      expect(appState.isSimulatedOffline, true);
      appState.toggleSimulatedOffline();
      expect(appState.isSimulatedOffline, false);
    });

    test('NotificationItem JSON parsing and state methods', () {
      final json = {
        'id': 'notif_tour_001',
        'title': 'High Footfall Alert: Mussoorie',
        'message': 'Mussoorie is currently experiencing peak visitor pressure (82/100).',
        'type': 'HIGH_PRESSURE_ALERT',
        'read': false,
        'createdAt': '2026-09-20T12:00:00Z',
        'relatedEntityId': 'mussoorie',
        'relatedEntityType': 'destination',
        'targetRole': 'tourist',
        'metadata': {'pressureScore': 82.0}
      };

      final notif = NotificationItem.fromJson(json);
      expect(notif.id, 'notif_tour_001');
      expect(notif.type, 'HIGH_PRESSURE_ALERT');
      expect(notif.read, false);
      expect(notif.relatedEntityId, 'mussoorie');

      final updated = notif.copyWith(read: true);
      expect(updated.read, true);
    });
  });

  group('PahadiPulse Flutter UI Widget Smoke Tests', () {
    testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome to PahadiPulse'), findsOneWidget);
      expect(find.text('Log In'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2));
      ConnectivityService().stopMonitoring();
    });

    testWidgets('HomeScreen smoke test', (WidgetTester tester) async {
      final appState = AppState();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Let initial microtasks settle
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      ConnectivityService().stopMonitoring();
    });
  });
}


