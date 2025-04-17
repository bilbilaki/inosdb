// lib/models/season.dart
import 'episode.dart';

class Season {
 final int seasonNumber;
 final List<Episode> episodes;

 // --- Fields potentially from TMDB (Optional) ---
 String? tmdbPosterPath;
 String? tmdbOverview;
 DateTime? tmdbAirDate;
 // ---

 Season({
 required this.seasonNumber,
 required this.episodes,
 // Optional TMDB fields
 this.tmdbPosterPath,
 this.tmdbOverview,
 this.tmdbAirDate,
 }) {
 // Sort episodes within the season by episode number when created
 episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
 }
}