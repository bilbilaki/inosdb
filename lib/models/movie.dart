// lib/models/movie.dart
import 'package:flutter/foundation.dart'; // For kDebugMode

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

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

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
  });

  String? getPosterUrl() {
    if (posterPath == null || posterPath!.isEmpty || posterPath == "nan") return null;
    // Handle potential leading slash if it's not already there in the base URL or path
    final path = posterPath!.startsWith('/') ? posterPath! : '/$posterPath';
    return imageBaseUrl + path;
  }

  String? getBackdropUrl() {
    // Use w780 or original for backdrops for better quality
    const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';
    if (backdropPath == null || backdropPath!.isEmpty || backdropPath == "nan") return null;
    final path = backdropPath!.startsWith('/') ? backdropPath! : '/$backdropPath';
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
      if (value == null || value.toString().isEmpty || value.toString().toLowerCase() == 'nan') {
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
        if (value == null || value.toString().isEmpty || value.toString().toLowerCase() == 'nan') return [];
        // Handles simple comma separation, might need adjustment
        // if format is more complex (e.g., JSON string within CSV)
        return value.toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
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
}