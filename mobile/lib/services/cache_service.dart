import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination.dart';
import '../models/itinerary.dart';
import '../models/report_draft.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _keyDestinations = 'pahadi_cache_destinations';
  static const String _keySavedDestIds = 'pahadi_cache_saved_dest_ids';
  static const String _keyItineraries = 'pahadi_cache_itineraries';
  static const String _keyReportDrafts = 'pahadi_cache_report_drafts';
  static const String _keyDestDetailPrefix = 'pahadi_cache_dest_detail_';
  static const String _keyLastSyncTime = 'pahadi_cache_last_sync_time';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 1. Destinations Caching
  Future<void> cacheDestinations(List<Destination> list) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = json.encode(list.map((d) => d.toJson()).toList());
      await prefs.setString(_keyDestinations, jsonStr);
      await prefs.setString(_keyLastSyncTime, DateTime.now().toIso8601String());
    } catch (e) {
      print('[CacheService] Error caching destinations: $e');
    }
  }

  Future<List<Destination>> getCachedDestinations() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keyDestinations);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = json.decode(jsonStr);
        return decoded.map((d) => Destination.fromJson(d)).toList();
      }
    } catch (e) {
      print('[CacheService] Error loading cached destinations: $e');
    }
    return [];
  }

  // 2. Destination Details Caching
  Future<void> cacheDestinationDetail(String id, Destination destination) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = json.encode(destination.toJson());
      await prefs.setString('$_keyDestDetailPrefix$id', jsonStr);
    } catch (e) {
      print('[CacheService] Error caching destination detail: $e');
    }
  }

  Future<Destination?> getCachedDestinationDetail(String id) async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString('$_keyDestDetailPrefix$id');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        return Destination.fromJson(decoded);
      }
    } catch (e) {
      print('[CacheService] Error loading cached destination detail: $e');
    }
    return null;
  }

  // 3. Saved Destination IDs Caching
  Future<void> cacheSavedDestinationIds(Set<String> ids) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setStringList(_keySavedDestIds, ids.toList());
    } catch (e) {
      print('[CacheService] Error caching saved destination IDs: $e');
    }
  }

  Future<Set<String>> getCachedSavedDestinationIds() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_keySavedDestIds);
      if (list != null) {
        return list.toSet();
      }
    } catch (e) {
      print('[CacheService] Error loading saved destination IDs: $e');
    }
    return {'kanatal', 'chopta'};
  }

  // 4. Itineraries Caching
  Future<void> cacheItinerary(GeneratedItinerary itinerary) async {
    try {
      final prefs = await _getPrefs();
      final existing = await getCachedItineraries();
      // Prepend or replace existing with same ID
      existing.removeWhere((it) => it.id == itinerary.id);
      existing.insert(0, itinerary);

      final jsonStr = json.encode(existing.map((it) => it.toJson()).toList());
      await prefs.setString(_keyItineraries, jsonStr);
    } catch (e) {
      print('[CacheService] Error caching itinerary: $e');
    }
  }

  Future<List<GeneratedItinerary>> getCachedItineraries() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keyItineraries);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = json.decode(jsonStr);
        return decoded.map((it) => GeneratedItinerary.fromJson(it)).toList();
      }
    } catch (e) {
      print('[CacheService] Error loading cached itineraries: $e');
    }
    return [];
  }

  // 5. Report Drafts Caching
  Future<void> saveReportDraft(ReportDraft draft) async {
    try {
      final prefs = await _getPrefs();
      final drafts = await getReportDrafts();
      drafts.removeWhere((d) => d.id == draft.id);
      drafts.insert(0, draft);

      final jsonStr = json.encode(drafts.map((d) => d.toJson()).toList());
      await prefs.setString(_keyReportDrafts, jsonStr);
    } catch (e) {
      print('[CacheService] Error saving report draft: $e');
    }
  }

  Future<List<ReportDraft>> getReportDrafts() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_keyReportDrafts);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = json.decode(jsonStr);
        return decoded.map((d) => ReportDraft.fromJson(d)).toList();
      }
    } catch (e) {
      print('[CacheService] Error loading report drafts: $e');
    }
    return [];
  }

  Future<void> deleteReportDraft(String id) async {
    try {
      final prefs = await _getPrefs();
      final drafts = await getReportDrafts();
      drafts.removeWhere((d) => d.id == id);
      final jsonStr = json.encode(drafts.map((d) => d.toJson()).toList());
      await prefs.setString(_keyReportDrafts, jsonStr);
    } catch (e) {
      print('[CacheService] Error deleting report draft: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _getPrefs();
      final timeStr = prefs.getString(_keyLastSyncTime);
      if (timeStr != null) {
        return DateTime.tryParse(timeStr);
      }
    } catch (_) {}
    return null;
  }
}
