// lib/models/episode.dart
import 'package:flutter/foundation.dart';

class Episode {
  final String seriesName; // Original name from CSV
  final String episodeIdentifier; // e.g., "S01E01" from CSV
  final int seasonNumber;
  final int episodeNumber;
  final String? url1080p;
  final String? url720p;
  final String? url480p;

  // --- Fields to be populated potentially from TMDB (Optional, depends on API calls) ---
  String? tmdbTitle; // Name from TMDB
  String? tmdbOverview;
  String? tmdbStillPath; // Like episode thumbnail
  DateTime? tmdbAirDate;
  // ---

  Episode({
    required this.seriesName,
    required this.episodeIdentifier,
    required this.seasonNumber,
    required this.episodeNumber,
    this.url1080p,
    this.url720p,
    this.url480p,
    // Optional TMDB fields
    this.tmdbTitle,
    this.tmdbOverview,
    this.tmdbStillPath,
    this.tmdbAirDate,
  });

  // Helper to get available quality URLs
  Map<String, String> getAvailableQualityUrls() {
    final Map<String, String> urls = {};
    if (url1080p != null && url1080p!.isNotEmpty) urls['1080p'] = url1080p!;
    if (url720p != null && url720p!.isNotEmpty) urls['720p'] = url720p!;
    if (url480p != null && url480p!.isNotEmpty) urls['480p'] = url480p!;
    return urls;
  }

  // Factory to create from CSV row data
  factory Episode.fromCsvInfo(String seriesName, List<dynamic> rowData) {
    String episodeId = rowData[1]?.toString() ?? 'S00E00'; // Column 2: Episode
    String? url1080 =
        rowData[2]?.toString().trim().nullIfEmpty; // Column 3: 1080p
    String? url720 =
        rowData[3]?.toString().trim().nullIfEmpty; // Column 4: 720p
    String? url480 =
        rowData[4]?.toString().trim().nullIfEmpty; // Column 5: 480p

    // Parse season and episode numbers from episodeId (format: S01E01)
    int seasonNum = 0;
    int episodeNum = 0;

    try {
      final match = RegExp(r'S(\d+)E(\d+)').firstMatch(episodeId);
      if (match != null) {
        seasonNum = int.parse(match.group(1)!);
        episodeNum = int.parse(match.group(2)!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error parsing episode numbers from '$episodeId': $e");
      }
    }

    return Episode(
      seriesName: seriesName,
      episodeIdentifier: episodeId,
      seasonNumber: seasonNum,
      episodeNumber: episodeNum,
      url1080p: url1080,
      url720p: url720,
      url480p: url480,
    );
  }

  @override
  String toString() {
    return 'Episode(series: $seriesName, id: $episodeIdentifier, S$seasonNumber E$episodeNumber, 1080p: ${url1080p != null}, 720p: ${url720p != null}, 480p: ${url480p != null})';
  }
}

// Helper extension for nullIfEmpty
extension StringExtension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
