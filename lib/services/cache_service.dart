import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _tmdbCacheKey = 'tmdb_series_cache';
  static const String _lastUpdateKey = 'last_tmdb_update';
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  // Save TMDB data to cache
  Future<void> cacheTmdbData(String seriesNameCsv, Map<String, dynamic> tmdbData) async {
    final cache = _prefs.getString(_tmdbCacheKey);
    Map<String, dynamic> cacheMap = {};
    
    if (cache != null) {
      cacheMap = json.decode(cache) as Map<String, dynamic>;
    }
    
    cacheMap[seriesNameCsv] = tmdbData;
    await _prefs.setString(_tmdbCacheKey, json.encode(cacheMap));
    await _updateLastCacheTime();
  }

  // Get cached TMDB data
  Map<String, dynamic>? getCachedTmdbData(String seriesNameCsv) {
    final cache = _prefs.getString(_tmdbCacheKey);
    if (cache != null) {
      final cacheMap = json.decode(cache) as Map<String, dynamic>;
      if (cacheMap.containsKey(seriesNameCsv)) {
        return cacheMap[seriesNameCsv] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Get all cached series names
  Set<String> getCachedSeriesNames() {
    final cache = _prefs.getString(_tmdbCacheKey);
    if (cache != null) {
      final cacheMap = json.decode(cache) as Map<String, dynamic>;
      return cacheMap.keys.toSet();
    }
    return {};
  }

  // Update last cache time
  Future<void> _updateLastCacheTime() async {
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get last cache update time
  DateTime? getLastUpdateTime() {
    final timestamp = _prefs.getInt(_lastUpdateKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Clear cache
  Future<void> clearCache() async {
    await _prefs.remove(_tmdbCacheKey);
    await _prefs.remove(_lastUpdateKey);
  }
} 