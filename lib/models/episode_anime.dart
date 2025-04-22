// lib/models/episode.dart
import 'package:flutter/foundation.dart';
import 'package:myapp/models/tv_series_anime.dart';

class EpisodeAnime {
  final String seriesNameCsv; // Original name from CSV (useful for debugging)
  final int seriesTmdbId;   // TMDB ID of the series this episode belongs to
  final String episodeIdentifier; // e.g., "S01E05" from CSV
  final int seasonNumber;
  final int episodeNumber;
  final String? url1080p;
  final String? url720p;
  final String? url540p;
  final String? url480p;
  final String? dubbedUrl;
  // --- Removed TMDB specific fields ---
 // String? tmdbTitle;
 // String? tmdbOverview;
 // String? tmdbStillPath;
 // DateTime? tmdbAirDate;
  // ---

  EpisodeAnime({
    required this.seriesNameCsv,
    required this.seriesTmdbId,
    required this.episodeIdentifier,
    required this.seasonNumber,
    required this.episodeNumber,
    this.url1080p,
    this.url720p,
    this.url540p,
    this.url480p,
    this.dubbedUrl,
  // Removed TMDB fields from constructor
  });

  // Helper to get available quality URLs (remains the same)
  Map<String, String> getAvailableQualityUrls() {
    final Map<String, String> urls = {};
    if (url1080p != null && url1080p!.isNotEmpty) urls['1080p'] = url1080p!;
    if (url720p != null && url720p!.isNotEmpty) urls['720p'] = url720p!;
    if (url540p != null && url540p!.isNotEmpty) urls['540p'] = url540p!;
    if (dubbedUrl != null && dubbedUrl!.isNotEmpty) urls['dubbed'] = dubbedUrl!; // Keep Dubbed
    if (url480p != null && url480p!.isNotEmpty) urls['480p'] = url480p!;
    return urls;
  }

  // Factory to create from CSV row data (UPDATED indices based on example)
  // Now requires seriesTmdbId to be passed in
  factory EpisodeAnime.fromCsvInfo(String seriesNameFromCsv, int seriesTmdbId, List<dynamic> rowData) {
     // Helper to safely get data from row, returning null if index out of bounds or value is null/empty
     String? safeGetString(int index) {
       if (index >= 0 && index < rowData.length && rowData[index] != null) {
          final val = rowData[index].toString().trim();
          return val.isNotEmpty ? val : null;
        }
       return null;
     }

     // Indices based on your example:
     // 0: Series Name (used for mapping, passed as seriesNameFromCsv)
     // 1: Episode Identifier (S01E05)
     // 2: 1080p URL
     // 3: 720p URL
     // 4: 540p URL
     // 5: 480p URL
     // 6: Dubbed URL

     String episodeId = safeGetString(1) ?? 'S00E00'; // Column 1: Episode Identifier
     String? url1080 = safeGetString(2)?.nullIfEmpty;   // Column 2: 1080p
     String? url720 = safeGetString(3)?.nullIfEmpty;    // Column 3: 720p
     String? url540 = safeGetString(4)?.nullIfEmpty;    // Column 4: 540p
     String? url480 = safeGetString(5)?.nullIfEmpty;    // Column 5: 480p
     String? dubbed = safeGetString(6)?.nullIfEmpty;    // Column 6: Dubbed

     // Parse season and episode numbers from episodeId (format: S01E05)
     int seasonNum = 0;
     int episodeNum = 0;

     try {
       final match = RegExp(r'[Ss](\d+)[Ee](\d+)').firstMatch(episodeId); // Case-insensitive S/E
       if (match != null && match.groupCount >= 2) {
         seasonNum = int.parse(match.group(1)!);
         episodeNum = int.parse(match.group(2)!);
       } else {
          if (kDebugMode) {
            print("Could not parse S/E numbers from '$episodeId' for series '$seriesNameFromCsv'. Defaulting to S0/E0.");
          }
       }
     } catch (e) {
        if (kDebugMode) {
         print("Error parsing episode numbers from '$episodeId' for series '$seriesNameFromCsv': $e");
        }
        // Keep default S0/E0 on error
     }


    // Validate that we have at least S/E numbers, otherwise skip? Or maybe allow S0E0?
    // For now, we allow S0E0 from the parsing default/error.
     if (seasonNum == 0 && episodeNum == 0 && episodeId != 'S00E00'){
       // Log a warning if parsing failed but the ID wasn't literally S00E00
       if (kDebugMode) {
          print("Warning: Episode identifier '$episodeId' for '$seriesNameFromCsv' parsed as S0E0.");
        }
     }

     return EpisodeAnime(
       seriesNameCsv: seriesNameFromCsv, // Store the name from CSV for reference
       seriesTmdbId: seriesTmdbId,       // Store the linked TMDB ID
       episodeIdentifier: episodeId,
       seasonNumber: seasonNum,
       episodeNumber: episodeNum,
       url1080p: url1080,
       url720p: url720,
       url540p: url540,
       url480p: url480,
       dubbedUrl: dubbed,
      );
   }

  @override
 String toString() {
   return 'Episode(seriesCsv: $seriesNameCsv, tmdbId: $seriesTmdbId, id: $episodeIdentifier, S$seasonNumber E$episodeNumber, #Qualities: ${getAvailableQualityUrls().length})';
 }
}

// Keep the helper extension if not globally defined
// extension StringExtension on String {
//  String? get nullIfEmpty => isEmpty ? null : this;
// }