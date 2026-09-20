import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/report.dart';
import '../models/provider.dart';
import '../models/itinerary.dart';
import '../models/user.dart';
import '../models/notification.dart';
import '../models/report_draft.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  final CacheService _cache = CacheService();
  final ConnectivityService _connectivity = ConnectivityService();

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
  List<Report> _allReports = [];
  Set<String> _savedDestinationIds = {'kanatal', 'chopta'};
  List<NotificationItem> _notificationsList = [];
  int _unreadNotificationsCount = 0;
  final List<Map<String, dynamic>> _notifications = [];
  List<ReportDraft> _reportDrafts = [];
  List<GeneratedItinerary> _cachedItineraries = [];

  GeneratedItinerary? _currentItinerary;

  // Connectivity & Offline State
  bool _isOffline = false;
  bool _isSyncingDrafts = false;

  // UI States
  bool _isLoadingDestinations = false;
  bool _isLoadingItinerary = false;
  bool _isLoadingReports = false;
  bool _isLoadingNotifications = false;
  String? _errorMessage;

  // Getters
  List<Destination> get destinations => _destinations;
  Map<String, dynamic>? get regionalPressure => _regionalPressure;
  List<LocalProvider> get providers => _providers;
  List<Report> get myReports => _myReports;
  List<Report> get allReports => _allReports;
  Set<String> get savedDestinationIds => _savedDestinationIds;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<NotificationItem> get notificationsList => _notificationsList;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  List<ReportDraft> get reportDrafts => _reportDrafts;
  List<GeneratedItinerary> get cachedItineraries => _cachedItineraries;
  GeneratedItinerary? get currentItinerary => _currentItinerary;

  bool get isOffline => _isOffline;
  bool get isSimulatedOffline => _connectivity.isSimulatedOffline;
  bool get isSyncingDrafts => _isSyncingDrafts;

  bool get isLoadingDestinations => _isLoadingDestinations;
  bool get isLoadingItinerary => _isLoadingItinerary;
  bool get isLoadingReports => _isLoadingReports;
  bool get isLoadingNotifications => _isLoadingNotifications;
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

    // 1. First restore cached state immediately for non-blocking offline start
    await _loadFromLocalCache();

    // 2. Start connectivity monitoring
    _connectivity.startMonitoring();
    _connectivity.onConnectivityChanged.listen((online) {
      _isOffline = !online;
      notifyListeners();
      if (online) {
        // Automatically sync pending drafts when connectivity is restored
        syncPendingReportDrafts();
      }
    });

    // 3. Fetch live data if connected
    await fetchDestinations();
    await fetchRegionalPressure();
    await fetchProviders();
    await fetchMyReports();
    await fetchAllReports();
    await fetchNotifications();
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final cachedDests = await _cache.getCachedDestinations();
      if (cachedDests.isNotEmpty) {
        _destinations = cachedDests;
      }
      _savedDestinationIds = await _cache.getCachedSavedDestinationIds();
      _reportDrafts = await _cache.getReportDrafts();
      _cachedItineraries = await _cache.getCachedItineraries();
      if (_cachedItineraries.isNotEmpty && _currentItinerary == null) {
        _currentItinerary = _cachedItineraries.first;
      }
      notifyListeners();
    } catch (e) {
      print("[AppState] Error restoring from cache: $e");
    }
  }

  // Connectivity Controls
  void toggleSimulatedOffline() {
    final next = !_connectivity.isSimulatedOffline;
    _connectivity.setSimulatedOffline(next);
    _isOffline = next;
    notifyListeners();
  }

  Future<bool> checkConnectivityAndSync() async {
    final online = await _connectivity.checkConnection();
    _isOffline = !online;
    notifyListeners();
    if (online) {
      await fetchDestinations();
      await fetchRegionalPressure();
      await syncPendingReportDrafts();
    }
    return online;
  }

  // 1. Destination Operations with Caching
  Future<void> fetchDestinations({String? district, String? status, String? search}) async {
    _isLoadingDestinations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_isOffline) {
        final live = await _api.getDestinations(district: district, status: status, search: search);
        if (live.isNotEmpty) {
          _destinations = live;
          await _cache.cacheDestinations(live);
        }
      } else {
        final cached = await _cache.getCachedDestinations();
        if (cached.isNotEmpty) {
          _destinations = cached;
        }
      }
    } catch (e) {
      _isOffline = true;
      final cached = await _cache.getCachedDestinations();
      if (cached.isNotEmpty) {
        _destinations = cached;
      }
      _errorMessage = "Network unavailable. Showing locally cached destinations.";
    } finally {
      _isLoadingDestinations = false;
      notifyListeners();
    }
  }

  Future<Destination?> getDestinationDetails(String id) async {
    try {
      if (!_isOffline) {
        final dest = await _api.getDestinationDetail(id);
        if (dest != null) {
          await _cache.cacheDestinationDetail(id, dest);
          return dest;
        }
      }
    } catch (_) {
      _isOffline = true;
    }

    // Fallback to locally cached detail
    final cached = await _cache.getCachedDestinationDetail(id);
    if (cached != null) return cached;

    // Fallback to destination list item
    return _destinations.where((d) => d.id == id).firstOrNull;
  }

  Future<void> fetchRegionalPressure() async {
    try {
      if (!_isOffline) {
        _regionalPressure = await _api.getRegionalPressure();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadInitialData() => initApp();

  void toggleSaveDestination(String id) {
    if (_savedDestinationIds.contains(id)) {
      _savedDestinationIds.remove(id);
    } else {
      _savedDestinationIds.add(id);
    }
    _cache.cacheSavedDestinationIds(_savedDestinationIds);
    notifyListeners();
  }

  bool isSaved(String id) => _savedDestinationIds.contains(id);
  bool isDestinationSaved(String id) => _savedDestinationIds.contains(id);

  // 2. Itinerary Planning with Caching
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
      if (_currentItinerary != null) {
        await _cache.cacheItinerary(_currentItinerary!);
        _cachedItineraries = await _cache.getCachedItineraries();
      }
      _isLoadingItinerary = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isOffline = true;
      _cachedItineraries = await _cache.getCachedItineraries();
      if (_cachedItineraries.isNotEmpty) {
        _currentItinerary = _cachedItineraries.first;
      }
      _errorMessage = "Network unavailable. Showing previously generated itinerary.";
      _isLoadingItinerary = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Local Providers
  Future<void> fetchProviders({String? category, String? destinationId}) async {
    try {
      if (!_isOffline) {
        _providers = await _api.getProviders(category: category, destinationId: destinationId);
        notifyListeners();
      }
    } catch (_) {}
  }

  // 4. Reports Operations with Offline Draft Management
  Future<void> fetchMyReports() async {
    _isLoadingReports = true;
    notifyListeners();
    try {
      if (!_isOffline) {
        _myReports = await _api.getMyReports(fallbackUserId: _currentUser?.uid);
      }
      _reportDrafts = await _cache.getReportDrafts();
    } catch (_) {} finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllReports() async {
    try {
      if (!_isOffline) {
        _allReports = await _api.getReports();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String?> uploadReportPhoto(List<int> bytes, String filename, String mimeType) async {
    if (_isOffline) return null;
    try {
      final res = await _api.uploadReportImage(
        fileBytes: bytes,
        filename: filename,
        contentType: mimeType,
      );
      return res['imageUrl'] as String?;
    } catch (e) {
      _errorMessage = "Photo upload failed: $e";
      notifyListeners();
      return null;
    }
  }

  Future<Report?> submitReport({
    required String destinationId,
    required String description,
    required double latitude,
    required double longitude,
    String? category,
    int? userSeverity,
    String? imageUrl,
  }) async {
    // If offline, save locally as draft
    if (_isOffline) {
      final dest = _destinations.where((d) => d.id == destinationId).firstOrNull;
      final draft = ReportDraft(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        destinationId: destinationId,
        destinationName: dest?.name ?? destinationId,
        description: description,
        category: category ?? 'OTHER',
        userSeverity: userSeverity ?? 3,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        createdAt: DateTime.now().toIso8601String(),
        syncStatus: 'PENDING',
      );
      await saveReportDraft(draft);
      return null;
    }

    try {
      final report = await _api.submitReport(
        destinationId: destinationId,
        description: description,
        latitude: latitude,
        longitude: longitude,
        category: category,
        userSeverity: userSeverity,
        imageUrl: imageUrl,
        userId: _currentUser?.uid,
        userName: _currentUser?.displayName,
      );
      _myReports.insert(0, report);
      _allReports.insert(0, report);
      notifyListeners();
      return report;
    } catch (e) {
      // Auto-fallback: save as draft on network failure
      _isOffline = true;
      final dest = _destinations.where((d) => d.id == destinationId).firstOrNull;
      final draft = ReportDraft(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        destinationId: destinationId,
        destinationName: dest?.name ?? destinationId,
        description: description,
        category: category ?? 'OTHER',
        userSeverity: userSeverity ?? 3,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        createdAt: DateTime.now().toIso8601String(),
        syncStatus: 'PENDING',
      );
      await saveReportDraft(draft);
      _errorMessage = "Saved to Offline Drafts. Will submit when connection returns.";
      notifyListeners();
      return null;
    }
  }

  // Report Draft Lifecycle
  Future<void> saveReportDraft(ReportDraft draft) async {
    await _cache.saveReportDraft(draft);
    _reportDrafts = await _cache.getReportDrafts();
    notifyListeners();
  }

  Future<void> deleteReportDraft(String id) async {
    await _cache.deleteReportDraft(id);
    _reportDrafts = await _cache.getReportDrafts();
    notifyListeners();
  }

  Future<int> syncPendingReportDrafts() async {
    if (_reportDrafts.isEmpty || _isOffline || _isSyncingDrafts) return 0;

    _isSyncingDrafts = true;
    notifyListeners();

    int syncedCount = 0;
    final draftsToSync = List<ReportDraft>.from(_reportDrafts);

    for (final draft in draftsToSync) {
      try {
        final report = await _api.submitReport(
          destinationId: draft.destinationId,
          description: draft.description,
          latitude: draft.latitude,
          longitude: draft.longitude,
          category: draft.category,
          userSeverity: draft.userSeverity,
          imageUrl: draft.imageUrl,
          userId: _currentUser?.uid,
          userName: _currentUser?.displayName,
        );
        _myReports.insert(0, report);
        _allReports.insert(0, report);
        await _cache.deleteReportDraft(draft.id);
        syncedCount++;
      } catch (e) {
        print("[AppState] Error syncing draft ${draft.id}: $e");
      }
    }

    _reportDrafts = await _cache.getReportDrafts();
    _isSyncingDrafts = false;
    notifyListeners();
    return syncedCount;
  }

  Future<Report?> getReportDetails(String id) async {
    return _api.getReportById(id);
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

  // 6. In-App Notification Operations
  Future<void> fetchNotifications({bool unreadOnly = false, String? type}) async {
    _isLoadingNotifications = true;
    notifyListeners();

    try {
      final role = _currentUser?.role ?? 'tourist';
      final list = await _api.getNotifications(
        role: role,
        type: type,
        unreadOnly: unreadOnly,
      );
      _notificationsList = list;
      _unreadNotificationsCount = list.where((n) => !n.read).length;
    } catch (e) {
      print("[AppState] fetchNotifications error: $e");
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationRead(String id) async {
    final idx = _notificationsList.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notificationsList[idx].read) {
      _notificationsList[idx] = _notificationsList[idx].copyWith(read: true);
      _unreadNotificationsCount = _notificationsList.where((n) => !n.read).length;
      notifyListeners();
      await _api.markNotificationRead(id);
    }
  }

  Future<void> markAllNotificationsRead() async {
    final role = _currentUser?.role ?? 'tourist';
    _notificationsList = _notificationsList.map((n) => n.copyWith(read: true)).toList();
    _unreadNotificationsCount = 0;
    notifyListeners();
    await _api.markAllNotificationsRead(role: role);
  }

  @override
  void dispose() {
    _connectivity.dispose();
    super.dispose();
  }
}
