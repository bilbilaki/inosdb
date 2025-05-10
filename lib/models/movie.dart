import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:tmdb_flutter/tmdb_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart' as c;

class VideoInfo {
  final String title;
  final String key; // YouTube key
  final String type; // e.g., "Trailer", "Opening", "Clip"

  VideoInfo({required this.title, required this.key, required this.type});
}

class Movie {
  final int id;
  final String title;
  final double voteAverage;
  final int voteCount;
  final String status;
  final DateTime? releaseDate; // Make nullable
  final int revenue;
  final int? runtime; // Make nullable
  final bool adult;
  final String? backdropPath; // Make nullable
  final int budget;
  final String? homepage; // Make nullable
  final String? imdbId; // Make nullable
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath; // Make nullable
  final String? tagline; // Make nullable
  final List<String> genres;
  final List<String> productionCompanies;
  final List<String> productionCountries;
  final List<String> spokenLanguages;
  final List<String> keywords;
  final String? source; // Make nullable
  final String? rawDownloadLinks; // Store the raw string
  final String? rawVideos;

  static const String imageBaseUrl =
      'https://inosdb.worker-inosuke.workers.dev/w500';

  Movie({
    required this.id,
    required this.title,
    required this.voteAverage,
    required this.voteCount,
    required this.status,
    this.releaseDate,
    required this.revenue,
    this.runtime,
    required this.adult,
    this.backdropPath,
    required this.budget,
    this.homepage,
    this.imdbId,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    this.tagline,
    required this.genres,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
    required this.keywords,
    this.source,
    this.rawDownloadLinks,
    this.rawVideos, // Make sure it's included
  });

  String? getPosterUrl() {
    if (posterPath == null || posterPath!.isEmpty || posterPath == "nan") {
      return null;
    }
    // Handle potential leading slash if it's not already there in the base URL or path
    final path = posterPath!.startsWith('/') ? posterPath! : '/$posterPath';
    return imageBaseUrl + path;
  }

  String? getBackdropUrl() {
    // Use w780 or original for backdrops for better quality
    const String backdropBaseUrl =
        'https://inosdb.worker-inosuke.workers.dev/w780';
    if (backdropPath == null ||
        backdropPath!.isEmpty ||
        backdropPath == "nan") {
      return null;
    }
    final path =
        backdropPath!.startsWith('/') ? backdropPath! : '/$backdropPath';
    return backdropBaseUrl + path;
  }

  // Helper to get a nicely formatted list of download links
  List<String> getDownloadLinksList() {
    if (rawDownloadLinks == null || rawDownloadLinks!.trim().isEmpty) {
      return [];
    }
    // Split by comma, trim whitespace, and filter out empty strings or non-http links
    return rawDownloadLinks!
        .split(',')
        .map((link) => link.trim())
        .where((link) => link.isNotEmpty && link.startsWith('http'))
        .toList();
  }

  // Factory constructor to create a Movie from a CSV row (List<dynamic>)
  factory Movie.fromCsvRow(List<dynamic> row) {
    // Helper function for safe parsing
    T? tryParse<T>(dynamic value, T Function(String) parser) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString().toLowerCase() == 'nan') {
        return null;
      }
      try {
        return parser(value.toString());
      } catch (e) {
        if (kDebugMode) {
          print("CSV Parsing Error for value '$value': $e");
        }
        return null;
      }
    }

    int? tryParseInt(dynamic value) => tryParse(value, int.parse);
    double? tryParseDouble(dynamic value) => tryParse(value, double.parse);
    DateTime? tryParseDate(dynamic value) => tryParse(value, DateTime.parse);
    bool parseBool(dynamic value) => value.toString().toUpperCase() == 'TRUE';

    // Helper to split potentially complex string fields (like genres)
    List<String> splitStringList(dynamic value) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString().toLowerCase() == 'nan') {
        return [];
      }
      // Handles simple comma separation, might need adjustment
      // if format is more complex (e.g., JSON string within CSV)
      return value
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Movie(
      id: tryParseInt(row[0]) ?? 0, // Default to 0 if parsing fails
      title: row[1]?.toString() ?? 'No Title',
      voteAverage: tryParseDouble(row[2]) ?? 0.0,
      voteCount: tryParseInt(row[3]) ?? 0,
      status: row[4]?.toString() ?? 'Unknown',
      releaseDate: tryParseDate(row[5]),
      revenue: tryParseInt(row[6]) ?? 0,
      runtime: tryParseInt(row[7]),
      adult: parseBool(row[8]),
      backdropPath: row[9]?.toString(),
      budget: tryParseInt(row[10]) ?? 0,
      homepage: row[11]?.toString(),
      imdbId: row[12]?.toString(),
      originalLanguage: row[13]?.toString() ?? 'N/A',
      originalTitle: row[14]?.toString() ?? 'No Original Title',
      overview: row[15]?.toString() ?? 'No Overview',
      popularity: tryParseDouble(row[16]) ?? 0.0,
      posterPath: row[17]?.toString(),
      tagline: row[18]?.toString(),
      // Assuming columns 19-23 are simple comma-separated strings
      genres: splitStringList(row[19]),
      productionCompanies: splitStringList(row[20]),
      productionCountries: splitStringList(row[21]),
      spokenLanguages: splitStringList(row[22]),
      keywords: splitStringList(row[23]),
      source: row[24]?.toString(),
      rawDownloadLinks: row[25]?.toString(), // Store the raw string
    );
  }
  List<VideoInfo> parseVideoData() {
    final List<VideoInfo> results = [];
    if (rawVideos == null ||
        rawVideos!.trim().isEmpty ||
        rawVideos!.toLowerCase() == 'nan') {
      return results;
    }

    // Example format: "Trailer: KEY1 | Opening Credits: KEY2 | Clip Name: KEY3"
    final entries = rawVideos!.split('|'); // Split entries by '|'

    for (String entry in entries) {
      entry = entry.trim();
      if (entry.isEmpty) continue;

      final parts = entry.split(':'); // Split title and key by ':'
      if (parts.length >= 2) {
        String title = parts[0].trim();
        String key = parts
            .sublist(1)
            .join(':')
            .trim(); // Join back in case title had ':'
        String type = "Clip"; // Default type

        // Basic type detection from title (customize as needed)
        if (title.toLowerCase().contains('trailer')) type = "Trailer";
        if (title.toLowerCase().contains('teaser')) type = "Teaser";
        if (title.toLowerCase().contains('opening')) type = "Opening";
        if (title.toLowerCase().contains('ending')) type = "Ending";

        if (key.isNotEmpty) {
          // Ensure key is not empty
          results.add(VideoInfo(title: title, key: key, type: type));
        }
      } else {
        // Maybe handle entries without ':' (e.g., just a key?)
        if (kDebugMode) print("Could not parse video entry: $entry");
      }
    }
    return results;
  }

  // Convert Movie object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'title': title,
      'release_date': releaseDate?.toIso8601String(),
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'genre_ids': genres.join(','),
      'original_language': originalLanguage,
      'video': false, // Default value since not in model
      'adult': adult ? 1 : 0, // SQLite doesn't have boolean type
    };
  }

  // Create Movie object from database Map
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: int.parse(map['id']),
      title: map['title'],
      voteAverage: map['vote_average'],
      voteCount: map['vote_count'],
      status: map['status'], // Default value since not in database
      releaseDate: map['release_date'] != null
          ? DateTime.parse(map['release_date'])
          : null,
      revenue: 0, // Default value since not in database
      runtime: map['runtime'], // Default value since not in database
      adult: map['adult'] == 1,
      backdropPath: map['backdrop_path'],
      budget: map['budget'], // Default value since not in database
      homepage: map['homepage'], // Default value since not in database
      imdbId: map['imdb_id'], // Default value since not in database
      originalLanguage: map['original_language'],
      originalTitle: map['title'], // Using title as fallback
      overview: map['overview'],
      popularity: map['popularity'],
      posterPath: map['poster_path'],
      tagline: null, // Default value since not in database
      genres: map['genres']?.toString().split(',') ?? [],
      productionCompanies: [], // Default value since not in database
      productionCountries: [], // Default value since not in database
      spokenLanguages: [], // Default value since not in database
      keywords: map['keywords'], // Default value since not in database
      source: null, // Default value since not in database
      rawDownloadLinks: null, // Default value since not in database
    );
  }
}

Future<void> launchVideo(String key) async {
  final Uri youtubeUrl = Uri.parse('https://www.youtube.com/watch?v=$key');
  final Uri youtubeAppUrl =
      Uri.parse('youtube://www.youtube.com/watch?v=$key'); // For app intent

  try {
    // Try opening in app first (might need platform-specific checks or alternative packages for better integration)
    if (await canLaunchUrl(youtubeAppUrl)) {
      await launchUrl(youtubeAppUrl, mode: LaunchMode.externalApplication);
    }
    // Fallback to web browser
    else if (await canLaunchUrl(youtubeUrl)) {
      await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
    } else {
      if (kDebugMode) print("Could not launch YouTube URL for key: $key");
      // Optionally show a message to the user
    }
  } catch (e) {
    if (kDebugMode) print("Error launching url: $e");
    // Optionally show a message to the user
  }
}

class TmdbVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final int size;
  final String type;
  final String? iso6391;
  final String? iso31661;
  final bool official;
  final DateTime? publishedAt;

  TmdbVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.size,
    required this.type,
    this.iso6391,
    this.iso31661,
    this.official = true,
    this.publishedAt,
  });

  factory TmdbVideo.fromCsvRow(List<dynamic> row) {
    // Helper function for safe parsing
    T? tryParse<T>(dynamic value, T Function(String) parser) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString().toLowerCase() == 'nan') {
        return null;
      }
      try {
        return parser(value.toString());
      } catch (e) {
        if (kDebugMode) {
          print("CSV Parsing Error for value '$value': $e");
        }
        return null;
      }
    }

    int? tryParseInt(dynamic value) => tryParse(value, int.parse);
    double? tryParseDouble(dynamic value) => tryParse(value, double.parse);
    DateTime? tryParseDate(dynamic value) => tryParse(value, DateTime.parse);
    bool parseBool(dynamic value) => value.toString().toUpperCase() == 'TRUE';

    // Helper to split potentially complex string fields (like genres)
    List<String> splitStringList(dynamic value) {
      if (value == null ||
          value.toString().isEmpty ||
          value.toString().toLowerCase() == 'nan') {
        return [];
      }
      // Handles simple comma separation, might need adjustment
      // if format is more complex (e.g., JSON string within CSV)
      return value
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return TmdbVideo(
      id: (row[0]) ?? 0, // Default to 0 if parsing fails
      name: row[1]?.toString() ?? 'No Title',
      key: c.AppConstants.tmdbapikey,
      size: 1080,
      type: '',

      site: row[11]?.toString() ?? '',
      official: true,
    );
  }
  List<VideoInfo> parseVideoData() {
    final List<VideoInfo> results = [];

    return results;
  }

  // Example format: "Trailer: KEY1 | Opening Credits: KEY2 | Clip Name: KEY3"

  // Basic type detection from title (customize as needed)
}
