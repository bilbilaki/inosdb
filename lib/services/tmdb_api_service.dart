// tmdb_api_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:myapp/models/tvseries_details.dart'; // Import the model

class TmdbApiService {
  final String _apiKey =
      "607e40af5bb66576f6fd7252d5529e24"; // Replace with your actual API ke
  final String _baseUrl = 'https://api.themoviedb.org/3';

  // Cache for storing results
  final _cache = <String, Map<String, dynamic>>{};
  static const _cacheTimeout = Duration(hours: 720);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 250);

  // Retry configuration
  static const _maxRetries = 5;
  static const _retryDelay = Duration(seconds: 1);

  TmdbApiService();

  Future<Map<String, dynamic>?> findAndFetchRawTvSeriesDetailsJsonpostscreen(
      String nameController,
      {int page = 1}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not configured');
    }

    // Check cache first
    final cacheKey = '${nameController}_$page';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // Rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }

    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final searchUri = Uri.parse(
            '$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(nameController)}&page=$page&include_adult=false');

        final searchResponse = await http.get(searchUri, headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        });

        _lastRequestTime = DateTime.now();

        if (searchResponse.statusCode == 200) {
          final searchData =
              json.decode(searchResponse.body) as Map<String, dynamic>;
          final results = searchData['results'] as List<dynamic>?;

          if (results != null && results.isNotEmpty) {
            final seriesId = (results[0] as Map<String, dynamic>)['id'] as int?;

            if (seriesId != null) {
              final detailsUri = Uri.parse(
                  '$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US&append_to_response=credits,external_ids,backdrop_path,poster_path,overview');

              final detailsResponse = await http.get(detailsUri);

              if (detailsResponse.statusCode == 200) {
                final detailsData =
                    json.decode(detailsResponse.body) as Map<String, dynamic>;

                // Cache the result
                _cache[cacheKey] = detailsData;

                // Schedule cache cleanup
                Future.delayed(_cacheTimeout)
                    .then((_) => _cache.remove(cacheKey));

                return detailsData;
              }
            }
          }
          return null;
        } else if (searchResponse.statusCode == 429) {
          // Too Many Requests
          if (attempt < _maxRetries) {
            await Future.delayed(_retryDelay * attempt);
            continue;
          }
        }

        _logError('API Error',
            'Status: ${searchResponse.statusCode}, Body: ${searchResponse.body}');
        return null;
      } catch (e) {
        _logError('Network Error', e.toString());
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
          continue;
        }
        return e as Map<String, dynamic>?;
      }
    }
    return log(e) as Map<String, dynamic>?;
  }

  void _logError(String type, String message) {
    if (kDebugMode) {
      print('$type: $message');
    }
  }
}
