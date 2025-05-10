import 'episode.dart';

class Season {
  final int seasonNumber;
  final List<Episode> episodes;

  // --- Removed TMDB specific fields ---
  // String? tmdbPosterPath;
  // String? tmdbOverview;
  // DateTime? tmdbReleaseDate;
  // ---

  Season({
    required this.seasonNumber,
    required this.episodes,
    // Removed TMDB fields from constructor
  }) {
    // Sort episodes within the season by episode number when created
    episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }
}