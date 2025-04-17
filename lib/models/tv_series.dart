// lib/models/tv_series.dart
import 'package:flutter/foundation.dart';
import 'season.dart'; // Import Season
import 'package:myapp/models/tvseries_details.dart'; // Import TvSeriesDetails

class TvSeries {
 // --- Details primarily from TMDB ---
 final int tmdbId;
 final String name; // TMDB name (preferred)
 final String overview;
 final String? posterPath; // Can be null
 final String? backdropPath; // Can be null
 final double voteAverage;
 final String? firstAirDate; // Can be null
 final List<Genre> genres;
 final int numberOfSeasons; // From TMDB
 final int numberOfEpisodes; // From TMDB
 final String status;
 // ... add other TMDB fields as needed (e.g., original_name, popularity)

 // --- Data structure from CSV/Provider ---
 final List<Season> seasons; // List of seasons containing episodes with URLs

 // --- Base URL for images ---
 static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
 static const String _backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';


 TvSeries({
 required this.tmdbId,
 required this.name,
 required this.overview,
 this.posterPath,
 this.backdropPath,
 required this.voteAverage,
 this.firstAirDate,
 required this.genres,
 required this.numberOfSeasons,
 required this.numberOfEpisodes,
 required this.status,
 required this.seasons, // Combined data
 });

 // Helper to get the full poster URL
 String? get fullPosterUrl =>
 posterPath != null && posterPath!.isNotEmpty ? '$_imageBaseUrl$posterPath' : null;

 // Helper to get the full backdrop URL
 String? get fullBackdropUrl =>
 posterPath != null && posterPath!.isNotEmpty ? '$_imageBaseUrl$posterPath' : null;
String formatForTmdb(String input) {
  // Replace spaces, underscores, and special characters with a single '-'
final String formatted = input.replaceAll(RegExp(r' _\:;+'), '-').toLowerCase();
  // Convert to lowercase
  return formatted.toLowerCase();
}
 // Factory constructor to create from TMDB JSON data
 // This ONLY creates the series-level info. Seasons/Episodes are added later.
 factory TvSeries.fromTmdbJson(dynamic input) {
   if (input is TvSeriesDetails) {
     // Handle TvSeriesDetails object
     return TvSeries(
       tmdbId: input.id,
       name: input.name,
       overview: input.overview,
       posterPath: input.posterPath,
       backdropPath: input.backdropPath,
       voteAverage: input.voteAverage,
       firstAirDate: input.firstAirDate,
       genres: input.genres,
       numberOfSeasons: input.numberOfSeasons,
       numberOfEpisodes: input.numberOfEpisodes,
       status: 'Unknown', // TvSeriesDetails doesn't have status field
       seasons: [], // Initially empty, added by provider
     );
   }
   
   // Handle raw JSON
   if (kDebugMode) {
     // print('Parsing TvSeriesDetails JSON: $input');
   }
   return TvSeries(
     tmdbId: input['id'] as int? ?? 0,
     name: input['name'] as String? ?? 'N/A',
     overview: input['overview'] as String? ?? '',
     posterPath: input['poster_path'] as String?,
     backdropPath: input['backdrop_path'] as String?,
     voteAverage: (input['vote_average'] as num?)?.toDouble() ?? 0.0,
     firstAirDate: input['first_air_date'] as String?,
     genres: (input['genres'] as List<dynamic>?)
         ?.map((genreJson) => Genre.fromJson(genreJson))
         .toList() ?? <Genre>[],
     numberOfSeasons: input['number_of_seasons'] as int? ?? 0,
     numberOfEpisodes: input['number_of_episodes'] as int? ?? 0,
     status: input['status'] as String? ?? 'Unknown',
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
 overview: overview,
 posterPath: posterPath,
 backdropPath: backdropPath,
 voteAverage: voteAverage,
 firstAirDate: firstAirDate,
 genres: genres,
 numberOfSeasons: numberOfSeasons,
 numberOfEpisodes: numberOfEpisodes,
 status: status,
 seasons: sortedSeasons, // Use the new or existing sorted list
 );
 }

 @override
 String toString() {
 return 'TvSeries(id: $tmdbId, name: $name, seasons: ${seasons.length})';
 }
}