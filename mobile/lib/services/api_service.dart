import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/destination.dart';
import '../models/report.dart';
import '../models/provider.dart';
import '../models/itinerary.dart';
import '../models/prediction.dart';
import '../models/user.dart';
import '../models/notification.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _customBaseUrl = AppConstants.localhostUrl;

  Future<void> initBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_api_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _customBaseUrl = savedUrl;
      }
    } catch (_) {}
  }

  void setBaseUrl(String url) async {
    _customBaseUrl = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_api_url', url);
    } catch (_) {}
  }

  String get baseUrl => _customBaseUrl;

  // 1. Destinations
  Future<List<Destination>> getDestinations({String? district, String? status, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (district != null && district.isNotEmpty) queryParams['district'] = district;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/destinations').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((d) => Destination.fromJson(d)).toList();
      }
    } catch (e) {
      print("[ApiService] getDestinations error: $e");
    }
    return _getFallbackDestinations();
  }

  Future<Destination?> getDestinationDetail(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/destinations/$id')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return Destination.fromJson(json.decode(res.body));
      }
    } catch (_) {}
    return _getFallbackDestinations().firstWhere((d) => d.id == id, orElse: () => _getFallbackDestinations().first);
  }

  Future<Map<String, dynamic>?> getDestinationPressureDetail(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/destinations/$id/pressure')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {}
    return null;
  }

  Future<DestinationPrediction?> getDestinationPrediction(String id, {int horizonDays = 3}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/destinations/$id/prediction?horizon_days=$horizonDays')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return DestinationPrediction.fromJson(json.decode(res.body));
      }
    } catch (_) {}
    return DestinationPrediction(
      destinationId: id,
      destinationName: id.toUpperCase(),
      currentScore: 78.0,
      predictedScore: 82.5,
      predictionHorizonDays: horizonDays,
      targetDate: DateTime.now().add(Duration(days: horizonDays)).toIso8601String().substring(0, 10),
      riskLevel: 'HIGH',
      modelConfidence: 0.94,
      confLower: 76.0,
      confUpper: 88.0,
      algorithm: 'GradientBoostingRegressor',
      primaryRiskFactor: 'Weekend Tourism Rush',
      isDemo: true,
      disclaimer: 'Synthetic demonstration prediction.',
    );
  }

  Future<List<Map<String, dynamic>>> getDestinationHistory(String id, {int days = 14}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/destinations/$id/history?days=$days')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['history'] != null) {
          return List<Map<String, dynamic>>.from(data['history']);
        }
      }
    } catch (_) {}
    return [];
  }

  // 2. Regional Pressure Aggregate
  Future<Map<String, dynamic>?> getRegionalPressure() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/region/pressure')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {}
    return {
      "averageScore": 34.5,
      "overallStatus": "MODERATE",
      "totalDestinations": 20,
      "statusDistribution": {"LOW": 14, "MODERATE": 3, "HIGH": 0, "CRITICAL": 3}
    };
  }

  // 3. AI Itinerary Generation
  Future<GeneratedItinerary> generateItinerary({
    required int days,
    required int travellers,
    required double budget,
    required List<String> interests,
    String? startingRegion,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/itineraries/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'daysCount': days,
          'travellersCount': travellers,
          'budgetPerPersonINR': budget,
          'interests': interests,
          'startingRegion': startingRegion ?? 'Dehradun / Rishikesh'
        }),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        return GeneratedItinerary.fromJson(json.decode(res.body));
      }
    } catch (e) {
      print("[ApiService] generateItinerary error: $e");
    }

    return _getFallbackItinerary(days, travellers, budget, interests);
  }

  // 4. Local Providers & Experiences
  Future<List<LocalProvider>> getProviders({String? category, String? destinationId}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (destinationId != null && destinationId.isNotEmpty) queryParams['destination_id'] = destinationId;

      final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((p) => LocalProvider.fromJson(p)).toList();
      }
    } catch (_) {}
    return _getFallbackProviders();
  }

  // 5. Citizen & Tourist Reporting
  Future<Report> submitReport({
    required String destinationId,
    required String description,
    required double latitude,
    required double longitude,
    String? category,
    int? userSeverity,
    String? imageUrl,
    String? userId,
    String? userName,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final payload = {
        'destinationId': destinationId,
        'description': description,
        'category': category ?? 'OTHER',
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl ?? '',
        'userId': userId ?? 'citizen_demo_user',
        'userName': userName ?? 'Pahadi Citizen',
      };
      if (userSeverity != null) {
        payload['userSeverity'] = userSeverity;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 7));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Report.fromJson(json.decode(res.body));
      } else {
        final err = json.decode(res.body);
        throw Exception(err['detail'] ?? 'Failed to submit report (${res.statusCode})');
      }
    } catch (e) {
      print("[ApiService] submitReport error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadReportImage({
    required List<int> fileBytes,
    required String filename,
    required String contentType,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/upload-image');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final err = json.decode(response.body);
        throw Exception(err['detail'] ?? 'Upload failed (${response.statusCode})');
      }
    } catch (e) {
      print("[ApiService] uploadReportImage error: $e");
      rethrow;
    }
  }

  Future<List<Report>> getMyReports({String? authToken, String? fallbackUserId}) async {
    try {
      final headers = <String, String>{};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      } else {
        headers['Authorization'] = 'Bearer citizen-token-demo';
      }

      final res = await http.get(
        Uri.parse('$baseUrl/reports/my'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((r) => Report.fromJson(r)).toList();
      }
    } catch (e) {
      print("[ApiService] getMyReports error: $e");
    }

    return getReports(userId: fallbackUserId);
  }

  Future<Report?> getReportById(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/reports/$id')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return Report.fromJson(json.decode(res.body));
      }
    } catch (e) {
      print("[ApiService] getReportById error: $e");
    }
    return null;
  }

  Future<List<Report>> getReports({String? userId, String? destinationId, String? category, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;
      if (destinationId != null && destinationId.isNotEmpty) queryParams['destinationId'] = destinationId;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/reports').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((r) => Report.fromJson(r)).toList();
      }
    } catch (e) {
      print("[ApiService] getReports error: $e");
    }
    return _getFallbackReports();
  }


  // Fallback Data
  List<Destination> _getFallbackDestinations() {
    return [
      Destination(
        id: 'kanatal',
        name: 'Kanatal',
        district: 'Tehri Garhwal',
        latitude: 30.4180,
        longitude: 78.3444,
        description: 'Pristine mountain ridge wrapped in dense deodar and pine forests. Low infrastructure strain and authentic village stays.',
        altitudeMeters: 2590,
        capacityDailyTourists: 4000,
        currentVisitorsEst: 950,
        tourismScore: 18.0,
        waterScore: 25.0,
        wasteScore: 15.0,
        trafficScore: 12.0,
        environmentScore: 20.0,
        pressureScore: 18.4,
        status: 'LOW',
        tags: ['Nature', 'Adventure', 'Relaxation', 'Photography'],
        popularSpots: ['Surkanda Devi Temple', 'Kodia Jungle', 'Tehri Viewpoint'],
        avgDailyBudgetINR: 2200,
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      ),
      Destination(
        id: 'chopta',
        name: 'Chopta',
        district: 'Rudraprayag',
        latitude: 30.4854,
        longitude: 79.1764,
        description: 'The Mini Switzerland of Uttarakhand, base camp for Tungnath and Chandrashila treks.',
        altitudeMeters: 2680,
        capacityDailyTourists: 3000,
        currentVisitorsEst: 750,
        tourismScore: 22.0,
        waterScore: 25.0,
        wasteScore: 20.0,
        trafficScore: 16.0,
        environmentScore: 40.0,
        pressureScore: 23.3,
        status: 'LOW',
        tags: ['Trekking', 'Snow Peaks', 'Spiritual', 'Wildlife'],
        popularSpots: ['Tungnath Temple', 'Chandrashila Peak', 'Deoria Tal'],
        avgDailyBudgetINR: 2100,
        imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
      ),
      Destination(
        id: 'mussoorie',
        name: 'Mussoorie',
        district: 'Dehradun',
        latitude: 30.4598,
        longitude: 78.0644,
        description: 'Queen of the Hills, experiencing acute weekend traffic bottlenecks on Mall Road and chronic water tanker demand.',
        altitudeMeters: 2005,
        capacityDailyTourists: 15000,
        currentVisitorsEst: 22400,
        tourismScore: 88.0,
        waterScore: 82.0,
        wasteScore: 76.0,
        trafficScore: 92.0,
        environmentScore: 45.0,
        pressureScore: 80.4,
        status: 'CRITICAL',
        tags: ['Colonial Heritage', 'Waterfalls', 'Cable Car', 'Shopping'],
        popularSpots: ['Mall Road', 'Kempty Falls', 'Gun Hill'],
        avgDailyBudgetINR: 3800,
        imageUrl: 'https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?auto=format&fit=crop&w=800&q=80',
      ),
      Destination(
        id: 'nainital',
        name: 'Nainital',
        district: 'Nainital',
        latitude: 29.3803,
        longitude: 79.4636,
        description: 'Iconic eye-shaped lake city facing severe lake-basin traffic and holiday parking saturation.',
        altitudeMeters: 2084,
        capacityDailyTourists: 12000,
        currentVisitorsEst: 18500,
        tourismScore: 86.0,
        waterScore: 79.0,
        wasteScore: 72.0,
        trafficScore: 89.0,
        environmentScore: 48.0,
        pressureScore: 78.1,
        status: 'CRITICAL',
        tags: ['Lakes', 'Boating', 'Shopping', 'Colonial Heritage'],
        popularSpots: ['Naini Lake', 'Naina Devi Temple', 'Snow View'],
        avgDailyBudgetINR: 3500,
        imageUrl: 'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?auto=format&fit=crop&w=800&q=80',
      ),
    ];
  }

  GeneratedItinerary _getFallbackItinerary(int days, int travellers, double budget, List<String> interests) {
    return GeneratedItinerary(
      id: 'itin_fallback',
      title: 'Sustainable Garhwal Eco Circuit ($days Days)',
      daysCount: days,
      travellersCount: travellers,
      budgetPerPersonINR: budget,
      totalEstimatedCostINR: budget * travellers * 0.9,
      pressureMitigationScore: 68.5,
      interests: interests,
      startingRegion: 'Dehradun',
      rationale: 'Routes through eco-friendly community homestays in Kanatal, Dhanaulti, and Chopta, avoiding congested bottlenecks.',
      days: [
        ItineraryDay(
          dayNumber: 1,
          destinationId: 'kanatal',
          destinationName: 'Kanatal',
          district: 'Tehri Garhwal',
          pressureLevel: 'LOW',
          pressureScore: 18.4,
          stayRecommendation: ItineraryStay(
            name: 'Pahadi Soul Village Homestay',
            type: 'Certified Village Homestay',
            costPerNightINR: 1800,
            bookingContact: '+91 98765 43210',
          ),
          activities: [
            ItineraryActivity(
              time: '09:00 AM',
              title: 'Kodia Jungle Forest Walk',
              description: 'Guided gentle nature trail with Himalayan flora and wildlife.',
              category: 'Nature',
              costEstimateINR: 350,
            ),
            ItineraryActivity(
              time: '01:30 PM',
              title: 'Traditional Garhwali Thali',
              description: 'Organic local meal featuring Mandua roti and Gahat dal.',
              category: 'Local Food',
              costEstimateINR: 350,
            ),
          ],
          travelNote: 'Smooth road transit with panoramic Himalayan vistas.',
        ),
      ],
    );
  }

  List<LocalProvider> _getFallbackProviders() {
    return [
      LocalProvider(
        id: 'prov_kanatal_01',
        name: 'Pahadi Soul Homestay & Organic Orchard',
        category: 'HOMESTAY',
        destinationId: 'kanatal',
        destinationName: 'Kanatal',
        ownerName: 'Suresh Negi',
        contactPhone: '+91 98765 43210',
        locationAddress: 'Upper Ridge Trail, Kanatal',
        rating: 4.9,
        reviewCount: 42,
        priceStartingINR: 1800,
        pricingUnit: 'per room/night',
        description: 'Authentic stone-and-wood Garhwali homestay serving Mandua roti, Bhatt ki dal, and wild rhododendron cordial with panoramic Himalayan vistas.',
        externalBookingUrl: 'https://pahadipulse.in/demo-providers/prov_kanatal_01',
        isDemo: true,
        disclaimer: 'Synthetic demo provider for hackathon demonstration.',
      ),
      LocalProvider(
        id: 'prov_chopta_02',
        name: 'Tungnath Summit Mountaineering Guides',
        category: 'LOCAL_GUIDE',
        destinationId: 'chopta',
        destinationName: 'Chopta',
        ownerName: 'Virendra Singh',
        contactPhone: '+91 98765 43213',
        locationAddress: 'Chopta Trailhead',
        rating: 5.0,
        reviewCount: 78,
        priceStartingINR: 1000,
        pricingUnit: 'per group trek',
        description: 'Local high-altitude guides specializing in Tungnath-Chandrashila sunrise ascents, snow trail safety, and birdwatching.',
        externalBookingUrl: 'https://pahadipulse.in/demo-providers/prov_chopta_02',
        isDemo: true,
        disclaimer: 'Synthetic demo provider for hackathon demonstration.',
      ),
      LocalProvider(
        id: 'prov_dhanaulti_01',
        name: 'Buransh Himalayan Cottage & Herbal Cafe',
        category: 'LOCAL_FOOD',
        destinationId: 'dhanaulti',
        destinationName: 'Dhanaulti',
        ownerName: 'Sunita Devi',
        contactPhone: '+91 98765 43214',
        locationAddress: 'Eco-Park Road, Dhanaulti',
        rating: 4.8,
        reviewCount: 65,
        priceStartingINR: 350,
        pricingUnit: 'per Pahadi Thali',
        description: 'Farm-to-table cuisine prepared with mountain millets, Jakhiya tempered potatoes, Kafuli spinach gravy, and freshly pressed wild berries.',
        externalBookingUrl: 'https://pahadipulse.in/demo-providers/prov_dhanaulti_01',
        isDemo: true,
        disclaimer: 'Synthetic demo provider for hackathon demonstration.',
      ),
    ];
  }

  List<Report> _getFallbackReports() {
    return [
      Report(
        id: 'rep_demo_01',
        userId: 'tourist_user',
        userName: 'Pahadi Traveler',
        destinationId: 'mussoorie',
        destinationName: 'Mussoorie',
        category: 'TRAFFIC',
        description: 'Severe 4km vehicular gridlock before Mall Road barrier.',
        imageUrl: '',
        latitude: 30.4598,
        longitude: 78.0644,
        aiCategory: 'TRAFFIC',
        aiSeverity: 4,
        aiConfidence: 0.95,
        aiExplanation: 'AI classified as transit bottleneck on primary access ghat.',
        status: 'AI_CLASSIFIED',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      )
    ];
  }

  // ----------------- In-App Notifications & Alerts -----------------
  Future<List<NotificationItem>> getNotifications({
    String? role = 'tourist',
    String? type,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (type != null && type.isNotEmpty && type != 'ALL') queryParams['type'] = type;
      if (unreadOnly) queryParams['unread_only'] = 'true';

      final uri = Uri.parse('$baseUrl/notifications').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((n) => NotificationItem.fromJson(n)).toList();
      }
    } catch (e) {
      print("[ApiService] getNotifications error: $e");
    }
    return _getFallbackNotifications(unreadOnly: unreadOnly);
  }

  Future<int> getUnreadNotificationCount({String? role = 'tourist'}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;

      final uri = Uri.parse('$baseUrl/notifications/unread-count').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        return data['unreadCount'] ?? 0;
      }
    } catch (e) {
      print("[ApiService] getUnreadNotificationCount error: $e");
    }
    return _getFallbackNotifications(unreadOnly: true).length;
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id/read');
      final res = await http.patch(uri).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      print("[ApiService] markNotificationRead error: $e");
      return false;
    }
  }

  Future<bool> markAllNotificationsRead({String? role = 'tourist'}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;

      final uri = Uri.parse('$baseUrl/notifications/mark-all-read').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final res = await http.post(uri).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      print("[ApiService] markAllNotificationsRead error: $e");
      return false;
    }
  }

  List<NotificationItem> _getFallbackNotifications({bool unreadOnly = false}) {
    final list = [
      NotificationItem(
        id: 'notif_tour_001',
        title: 'High Footfall Alert: Mussoorie & Mall Road',
        message: 'Mussoorie is currently experiencing peak visitor pressure (82/100). For a serene Himalayan retreat, explore nearby Dhanaulti or Kanatal.',
        type: 'HIGH_PRESSURE_ALERT',
        read: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        relatedEntityId: 'mussoorie',
        relatedEntityType: 'destination',
        targetRole: 'tourist',
        metadata: const {'currentPressure': 82.0, 'alternative': 'Dhanaulti'},
      ),
      NotificationItem(
        id: 'notif_tour_002',
        title: 'Eco-Smart Route Optimization Available',
        message: 'Your Garhwal circuit itinerary has an updated dynamic route recommendation saving 45 minutes travel time and mitigating peak pressure.',
        type: 'ITINERARY_UPDATE',
        read: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)).toIso8601String(),
        relatedEntityId: 'itin_sample_garhwal',
        relatedEntityType: 'itinerary',
        targetRole: 'tourist',
        metadata: const {'mitigationScore': 76.5, 'savingMinutes': 45},
      ),
      NotificationItem(
        id: 'notif_tour_003',
        title: 'Saved Destination: Chopta at Optimal Capacity',
        message: 'Chopta is currently enjoying serene green pressure (22/100) with clear weather. Ideal conditions for the Tungnath alpine trail.',
        type: 'SAVED_DESTINATION_ALERT',
        read: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        relatedEntityId: 'chopta',
        relatedEntityType: 'destination',
        targetRole: 'tourist',
        metadata: const {'pressureScore': 22.0, 'status': 'LOW'},
      ),
      NotificationItem(
        id: 'notif_tour_004',
        title: 'Uttarakhand State Travel Advisory',
        message: 'Autumn eco-tourism permits and high-altitude trekking registrations are now open with localized community homestay credits.',
        type: 'GENERAL_ANNOUNCEMENT',
        read: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        relatedEntityId: 'advisory_autumn',
        relatedEntityType: 'announcement',
        targetRole: 'tourist',
        metadata: const {'season': 'Autumn'},
      ),
    ];

    if (unreadOnly) {
      return list.where((n) => !n.read).toList();
    }
    return list;
  }
}

