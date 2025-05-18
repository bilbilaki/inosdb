// tv_series_details.dart
// For kDebugMode

class TvSeriesDetails {
  final int id;
  final String name;
  final String overview;
  final String? posterPath; // Can be null
  final String? backdropPath; // Can be null
  final double voteAverage;
  final String? firstAirDate; // Can be null
  final List<Genre> genres;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  // Add any other fields you need from the TMDB response

  // Base URL for images (you can choose different sizes like w500, w780, original)
  static const String _imageBaseUrl = 'https://inosdb.worker-inosuke.workers.dev/original';

  TvSeriesDetails({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.firstAirDate,
    required this.genres,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
  });

  // Helper to get the full poster URL
  String? get fullPosterUrl =>
      posterPath != null ? '$_imageBaseUrl$posterPath' : null;

  // Helper to get the full backdrop URL
  String? get fullBackdropUrl =>
      posterPath != null ? '$_imageBaseUrl$posterPath' : null;

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'first_air_date': firstAirDate,
      'genres': genres.map((g) => g.toJson()).toList(),
      'number_of_seasons': numberOfSeasons,
      'number_of_episodes': numberOfEpisodes,
    };
  }

  // Factory constructor to create from JSON
  factory TvSeriesDetails.fromJson(Map<String, dynamic> json) {
    return TvSeriesDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      firstAirDate: json['first_air_date'] as String?,
      genres: (json['genres'] as List<dynamic>)
          .map((g) => Genre.fromJson(g as Map<String, dynamic>))
          .toList(),
      numberOfSeasons: json['number_of_seasons'] as int,
      numberOfEpisodes: json['number_of_episodes'] as int,
    );
  }

  // Method to convert instance to String for printing
  @override
  String toString() {
    return '''
TvSeriesDetails {
  id: $id,
  name: $name,
  overview: ${overview.substring(0, overview.length > 50 ? 50 : overview.length)}...,
  posterPath: $posterPath,
  backdropPath: $backdropPath,
  fullPosterUrl: $fullPosterUrl,
  fullBackdropUrl: $fullBackdropUrl,
  voteAverage: $voteAverage,
  firstAirDate: $firstAirDate,
  numberOfSeasons: $numberOfSeasons,
  numberOfEpisodes: $numberOfEpisodes,
  genres: ${genres.map((g) => g.name).join(', ')}
}''';
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
