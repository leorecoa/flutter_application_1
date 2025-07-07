import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _appointmentsCacheKey = 'cached_appointments';
  static const String _dashboardCacheKey = 'cached_dashboard';
  static const String _lastSyncKey = 'last_sync';

  Future<void> cacheAppointments(List<Map<String, dynamic>> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appointmentsCacheKey, jsonEncode(appointments));
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>?> getCachedAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_appointmentsCacheKey);
    if (cached != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cached));
    }
    return null;
  }

  Future<void> cacheDashboard(Map<String, dynamic> dashboard) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dashboardCacheKey, jsonEncode(dashboard));
  }

  Future<Map<String, dynamic>?> getCachedDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_dashboardCacheKey);
    if (cached != null) {
      return Map<String, dynamic>.from(jsonDecode(cached));
    }
    return null;
  }

  Future<bool> isCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheValidityMs = 5 * 60 * 1000; // 5 minutos
    return (now - lastSync) > cacheValidityMs;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appointmentsCacheKey);
    await prefs.remove(_dashboardCacheKey);
    await prefs.remove(_lastSyncKey);
  }
}