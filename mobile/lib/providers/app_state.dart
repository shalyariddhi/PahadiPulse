import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/report.dart';
import '../models/provider.dart';
import '../models/itinerary.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Authentication State
  UserProfile? _currentUser = UserProfile(
    uid: 'tourist_pahadi_01',
    email: 'traveler@pahadipulse.in',
    displayName: 'Pahadi Traveler',
    role: 'tourist',
    createdAt: DateTime.now().toIso8601String(),
  );
  bool _isAuthenticated = true;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Data Collections
  List<Destination> _destinations = [];
  Map<String, dynamic>? _regionalPressure;
  List<LocalProvider> _providers = [];
  List<Report> _myReports = [];
  final Set<String> _savedDestinationIds = {'kanatal', 'chopta'};
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": "notif_01",
      "title": "Mussoorie Mall Road Choke Alert",
      "body": "Traffic density is at 92%. We recommend routing towards Dhanaulti or Kanatal for seamless travel.",
      "time": "15m ago",
      "isRead": false,
      "severity": "CRITICAL"
    },
    {
      "id": "notif_02",
      "title": "Auli Snowfall Warning",
      "body": "Light snowfall forecast in Joshimath-Auli corridor. Ensure anti-skid chains on vehicles.",
      "time": "2h ago",
      "isRead": false,
      "severity": "MODERATE"
    },
    {
      "id": "notif_03",
      "title": "Welcome to PahadiPulse!",
      "body": "Your eco-tourism companion for exploring Uttarakhand sustainably.",
      "time": "1d ago",
      "isRead": true,
      "severity": "INFO"
    }
  ];

  GeneratedItinerary? _currentItinerary;

  // UI States
  bool _isLoadingDestinations = false;
  bool _isLoadingItinerary = false;
  bool _isLoadingReports = false;
  String? _errorMessage;

  // Getters
  List<Destination> get destinations => _destinations;
  Map<String, dynamic>? get regionalPressure => _regionalPressure;
  List<LocalProvider> get providers => _providers;
  List<Report> get myReports => _myReports;
  Set<String> get savedDestinationIds => _savedDestinationIds;
  List<Map<String, dynamic>> get notifications => _notifications;
  GeneratedItinerary? get currentItinerary => _currentItinerary;

  bool get isLoadingDestinations => _isLoadingDestinations;
  bool get isLoadingItinerary => _isLoadingItinerary;
  bool get isLoadingReports => _isLoadingReports;
  String? get errorMessage => _errorMessage;

  List<Destination> get lowerPressureDestinations =>
      _destinations.where((d) => d.isLow || d.isModerate).toList();

  List<Destination> get popularDestinations =>
      _destinations.where((d) => d.isCritical || d.isHigh).toList();

  List<Destination> get savedDestinations =>
      _destinations.where((d) => _savedDestinationIds.contains(d.id)).toList();

  AppState() {
    initApp();
  }

  Future<void> initApp() async {
    await _api.initBaseUrl();
    await fetchDestinations();
    await fetchRegionalPressure();
    await fetchProviders();
    await fetchMyReports();
  }

  // 1. Destination Operations
  Future<void> fetchDestinations({String? district, String? status, String? search}) async {
    _isLoadingDestinations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinations = await _api.getDestinations(district: district, status: status, search: search);
    } catch (e) {
      _errorMessage = "Failed to load destinations: $e";
    } finally {
      _isLoadingDestinations = false;
      notifyListeners();
    }
  }

  Future<void> fetchRegionalPressure() async {
    try {
      _regionalPressure = await _api.getRegionalPressure();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadInitialData() => initApp();

  void toggleSaveDestination(String id) {
    if (_savedDestinationIds.contains(id)) {
      _savedDestinationIds.remove(id);
    } else {
      _savedDestinationIds.add(id);
    }
    notifyListeners();
  }

  bool isSaved(String id) => _savedDestinationIds.contains(id);
  bool isDestinationSaved(String id) => _savedDestinationIds.contains(id);

  // 2. Itinerary Planning
  Future<bool> planTrip({
    required int days,
    required int travellers,
    required double budget,
    required List<String> interests,
    String? startingRegion,
  }) async {
    _isLoadingItinerary = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentItinerary = await _api.generateItinerary(
        days: days,
        travellers: travellers,
        budget: budget,
        interests: interests,
        startingRegion: startingRegion,
      );
      _isLoadingItinerary = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to generate itinerary: $e";
      _isLoadingItinerary = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Local Providers
  Future<void> fetchProviders({String? category, String? destinationId}) async {
    try {
      _providers = await _api.getProviders(category: category, destinationId: destinationId);
      notifyListeners();
    } catch (_) {}
  }

  // 4. Reports Operations
  Future<void> fetchMyReports() async {
    _isLoadingReports = true;
    notifyListeners();
    try {
      _myReports = await _api.getReports(userId: _currentUser?.uid);
    } catch (_) {} finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport({
    required String destinationId,
    required String description,
    required double latitude,
    required double longitude,
    String? category,
  }) async {
    try {
      final report = await _api.submitReport(
        destinationId: destinationId,
        description: description,
        latitude: latitude,
        longitude: longitude,
        category: category,
        userId: _currentUser?.uid,
        userName: _currentUser?.displayName,
      );
      _myReports.insert(0, report);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to submit report: $e";
      notifyListeners();
      return false;
    }
  }

  // 5. Auth Operations
  void login(String email, String password, {String role = 'tourist'}) {
    _currentUser = UserProfile(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0].toUpperCase(),
      role: role,
      createdAt: DateTime.now().toIso8601String(),
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n["id"] == id);
    if (idx != -1) {
      _notifications[idx]["isRead"] = true;
      notifyListeners();
    }
  }
}
