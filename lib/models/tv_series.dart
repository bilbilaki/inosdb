// lib/models/tv_series.dart
import 'package:flutter/foundation.dart';
import 'package:myapp/models/movie.dart'; // Import VideoInfo if defined there or define here
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'season.dart';
enum LoadingStatus {
  idle,
  loading,
  loaded,
  error,
}

// Helper function for safe parsing (can be moved to a utility file)
T? tryParse<T>(dynamic value, T Function(String) parser) {
  if (value == null || value.toString().isEmpty || value.toString().toLowerCase() == 'nan' || value.toString().toLowerCase() == 'none') {
    return null;
  }
  try {
    // Handle potential double strings like "6.5" before parsing int
    if (T == int && value is String && value.contains('.')) {
       final doubleVal = double.tryParse(value);
       return doubleVal?.toInt() as T?;
    }
    return parser(value.toString().trim());
  } catch (e) {
    if (kDebugMode) {
      print("CSV Parsing Error for value '$value' as type $T: $e");
    }
    return null;
  }
}

int? tryParseInt(dynamic value) => tryParse(value, int.parse);
double? tryParseDouble(dynamic value) => tryParse(value, double.parse);
DateTime? tryParseDate(dynamic value) => tryParse(value, DateTime.parse);
bool parseBool(dynamic value) {
   final lowerVal = value?.toString().toLowerCase();
   return lowerVal == 'true' || lowerVal == '1';
}

// Helper to split potentially complex string fields
List<String> splitStringList(dynamic value, {String separator = ','}) {
  if (value == null || value.toString().isEmpty || value.toString().toLowerCase() == 'nan' || value.toString().toLowerCase() == 'none') return [];
  // Handles simple separator splitting, trims whitespace, removes empty strings
  return value
      .toString()
      .split(separator)
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

class TvSeries {
  // --- Details primarily from CSV ---
  final int tmdbId;           // Column 0: tmdb_id
  final String name;           // Column 1: series (often used as display name)
  final String status;         // Column 2: status
  final DateTime? firstAirDate; // Column 3: release_date (parsed)
  final int? runtime;        // Column 4: runtime
  final String overview;       // Column 5: overview
  final double voteAverage;    // Column 6: vote_average
  final int voteCount;        // Column 7: vote_count
  final List<String> genres;     // Column 8: genres (comma-separated)
  final List<String> keywords;   // Column 9: keywords (comma-separated)
  final String originalName;   // Column 10: original_name
  final String? posterPath;     // Column 11: poster_path
  final String? backdropPath;   // Column 12: backdrop_path
  final double popularity;     // Column 13: popularity
  final String originalLanguage; // Column 14: original_language
  final String type;           // Column 15: type
  final int? numberOfEpisodes; // Column 16: number_of_episodes
  final int? numberOfSeasons;  // Column 17: number_of_seasons
  final String? homepage;       // Column 18: homepage
  // You might want to parse cast (19), crew (20), videos (21) if needed later
   final List<String> cast;
   final List<String> crew;
   final List<String> videos;
   final String? rawVideos; 

  // --- Data structure for combined data ---
  final List<Season> seasons; // Populated by provider

  // --- Base URL for images (keep this) ---
  static const String _imageBaseUrl = 'https://inosdb.worker-inosuke.workers.dev/w500';
  static const String _backdropBaseUrl = 'https://inosdb.worker-inosuke.workers.dev/w780'; // Use a higher res for backdrop

  TvSeries({
    required this.tmdbId,
    required this.name,
    required this.status,
    this.firstAirDate,
    this.runtime,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.genres,
    required this.keywords,
    required this.originalName,
    this.posterPath,
    this.backdropPath,
    required this.popularity,
    required this.originalLanguage,
    required this.type,
    this.numberOfEpisodes,
    this.numberOfSeasons,
    this.homepage,
    required this.cast,
    required this.crew,
    required this.videos,
    required this.seasons,
    this.rawVideos, // Add to constructor
  });

  // Helper to get the full poster URL
  String? get fullPosterUrl {
     if (posterPath == null || posterPath!.isEmpty || posterPath == "nan" || posterPath == "None") return null;
     final path = posterPath!.startsWith('/') ? posterPath! : '/$posterPath';
     return '$_imageBaseUrl$path';
  }

  // Helper to get the full backdrop URL
  String? get fullBackdropUrl {
     if (backdropPath == null || backdropPath!.isEmpty || backdropPath == "nan" || backdropPath == "None") return null;
     final path = backdropPath!.startsWith('/') ? backdropPath! : '/$backdropPath';
     return '$_backdropBaseUrl$path'; // Use higher res backdrop url
  }

  // Factory constructor to create from CSV row data
  factory TvSeries.fromCsvRow(List<dynamic> row) {
    // Ensure row has enough columns to avoid RangeError
    dynamic safeGet(int index, [dynamic defaultValue = null]) {
         return (row.length > index && row[index] != null) ? row[index] : defaultValue;
     }

    DateTime? parsedDate = tryParseDate(safeGet(3)); // Column 3: release_date

    return TvSeries(
        tmdbId: tryParseInt(safeGet(0)) ?? 0, // Column 0: tmdb_id - Default to 0 if invalid
        name: safeGet(1)?.toString() ?? 'Unknown Series', // Column 1: series
        status: safeGet(2)?.toString() ?? 'Unknown',   // Column 2: status
        firstAirDate: parsedDate,                   // Column 3: release_date
        runtime: tryParseInt(safeGet(4)),          // Column 4: runtime
        overview: safeGet(5)?.toString() ?? '',       // Column 5: overview
        voteAverage: tryParseDouble(safeGet(6)) ?? 0.0, // Column 6: vote_average
        voteCount: tryParseInt(safeGet(7)) ?? 0,      // Column 7: vote_count
        genres: splitStringList(safeGet(8)),         // Column 8: genres
        keywords: splitStringList(safeGet(9)),       // Column 9: keywords
        originalName: safeGet(10)?.toString() ?? 'Unknown Original Name', // Column 10: original_name
        posterPath: safeGet(11)?.toString(),           // Column 11: poster_path
        backdropPath: safeGet(12)?.toString(),         // Column 12: backdrop_path
        popularity: tryParseDouble(safeGet(13)) ?? 0.0, // Column 13: popularity
        originalLanguage: safeGet(14)?.toString() ?? 'N/A', // Column 14: original_language
        type: safeGet(15)?.toString() ?? 'Unknown',   // Column 15: type
        numberOfEpisodes: tryParseInt(safeGet(16)),  // Column 16: number_of_episodes
        numberOfSeasons: tryParseInt(safeGet(17)),   // Column 17: number_of_seasons
        homepage: safeGet(18)?.toString(),           // Column 18: homepage
        cast: splitStringList(safeGet(19), separator: '|'),    // Example if needed
        crew: splitStringList(safeGet(20), separator: '|'),   // Example if needed
        videos: splitStringList(safeGet(21), separator: '|'), // Example if needed
         rawVideos: safeGet(21)?.toString(),
        seasons: [], // Initially empty, added by provider
      );
  }

  // Method to create a new TvSeries instance by adding seasons to an existing one
  TvSeries copyWith({
    List<Season>? seasons,
  }) {
    // Sort seasons by number before assigning
    final sortedSeasons = seasons ?? this.seasons;
    sortedSeasons.sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    return TvSeries(
        tmdbId: tmdbId,
        name: name,
        status: status,
        firstAirDate: firstAirDate,
        runtime: runtime,
        overview: overview,
        voteAverage: voteAverage,
        voteCount: voteCount,
        genres: genres,
        keywords: keywords,
        originalName: originalName,
        posterPath: posterPath,
        backdropPath: backdropPath,
        popularity: popularity,
        originalLanguage: originalLanguage,
        type: type,
        numberOfEpisodes: numberOfEpisodes,
        numberOfSeasons: numberOfSeasons,
        homepage: homepage,
        cast: cast,
        crew: crew,
        videos: videos,
        seasons: sortedSeasons, // Use the new or existing sorted list
      );
  }
   List<VideoInfo> parseVideoData() {
   final List<VideoInfo> results = [];
   if (rawVideos == null || rawVideos!.trim().isEmpty || rawVideos!.toLowerCase() == 'nan') {
     return results;
   }
   final entries = rawVideos!.split('|');
   for (String entry in entries) {
     entry = entry.trim();
     if (entry.isEmpty) continue;
     final parts = entry.split(':');
     if (parts.length >= 2) {
       String title = parts[0].trim();
       String key = parts.sublist(1).join(':').trim();
       String type = "Clip";
       if (title.toLowerCase().contains('trailer')) type = "Trailer";
       if (title.toLowerCase().contains('teaser')) type = "Teaser";
       if (title.toLowerCase().contains('opening')) type = "Opening";
       if (title.toLowerCase().contains('ending')) type = "Ending";

       if (key.isNotEmpty) {
         results.add(VideoInfo(title: title, key: key, type: type));
       }
     } else {
       if (kDebugMode) print("Could not parse video entry: $entry");
     }
   }
   return results;
 }

 Future<void> launchVideo(String key) async {
   final Uri youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$key');
   final Uri youtubeAppUrl = Uri.parse('youtube://www.youtube.com/watch?v=$key');
    try {
     if (await canLaunchUrl(youtubeAppUrl)) {
       await launchUrl(youtubeAppUrl, mode: LaunchMode.externalApplication);
     }
     else if (await canLaunchUrl(youtubeUrl)) {
       await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
     } else {
        if (kDebugMode) print("Could not launch YouTube URL for key: $key");
     }
   } catch (e) {
     if (kDebugMode) print("Error launching url: $e");
   }
 }


  @override
  String toString() {
    return 'TvSeries(id: $tmdbId, name: $name, seasons: ${seasons.length})';
  }

  // Optional: Add Genre class if needed for JSON structure, but for CSV it's often just strings
  // Replace the `Genre.fromJson` calls if you were using a Genre class before
}

// If you were using a Genre class like this from TMDB:
 class Genre {
   final int id; // May not be available from CSV
   final String name;

   Genre({required this.id, required this.name});

   // Keep this if you might merge with TMDB data later, otherwise remove
   factory Genre.fromJson(Map<String, dynamic> json) {
     return Genre(
       id: json['id'] as int? ?? 0,
       name: json['name'] as String? ?? 'Unknown Genre',
     );
   }
 }
// If you only have genre names (strings) from the CSV, TvSeries can just store List<String> genres.
// Make sure the TvSeries class uses List<String> genres if you remove the Genre class.
// (The provided TvSeries.fromCsvRow already assumes List<String>)

// Add the helper extension if it's not globally available
extension StringExtension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}