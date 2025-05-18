// models/tv_series.dart
import 'package:miko/models/season.dart';
enum LoadingStatus {
  idle,
  loading,
  loaded,
  error,
}
class TvSeries {
  final int tmdbId;
  final String name;
  final String originalName;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<String> genres;
  final List<String>? keywords;
  final DateTime? firstAirDate;
  final List<Season> seasons;

  TvSeries({
    required this.tmdbId,
    required this.name,
    required this.originalName,
    this.overview,
     this.posterPath,
    this.backdropPath,
    required this.genres,
    this.keywords,
    this.firstAirDate,
    this.seasons = const [],
  });

  factory TvSeries.fromMap(Map<String, dynamic> map) {
    return TvSeries(
      tmdbId: map['tmdb_id'] ?? map['id'] ?? 0,
      name: map['name'] ?? '',
      originalName: map['original_name'] ?? map['name'] ?? '',
      overview: map['overview'],
      posterPath: map['poster_path'] ?? '',
      backdropPath: map['backdrop_path'],
      genres: (map['genres'] as String? ?? '').split(',').map((e) => e.trim()).toList(),
      keywords: (map['keywords'] as String? ?? '').split(',').map((e) => e.trim()).toList(),
      firstAirDate: map['first_air_date'] != null 
          ? DateTime.parse(map['first_air_date']) 
          : null,
    );
  }

  TvSeries copyWith({
    List<Season>? seasons,
    // other fields...
  }) {
    return TvSeries(
      tmdbId: tmdbId,
      name: name,
      originalName: originalName,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      genres: genres,
      keywords: keywords,
      firstAirDate: firstAirDate,
      seasons: seasons ?? this.seasons,
    );
  }
}