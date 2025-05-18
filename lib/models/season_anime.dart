// lib/models/season.dart
import 'episode_anime.dart';

class SeasonAnime {
  final int seasonNumber;
  final List<EpisodeAnime> episodes;

  // --- Removed TMDB specific fields ---
  // String? tmdbPosterPath;
  // String? tmdbOverview;
  // DateTime? tmdbReleaseDate;
  // ---

  SeasonAnime({
    required this.seasonNumber,
    required this.episodes,
    // Removed TMDB fields from constructor
  }) {
    // Sort episodes within the season by episode number when created
    episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }
}