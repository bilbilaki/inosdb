import 'dart:math';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/providers/anime_provider.dart';

class RandomAnimeUtils {
  static final Random _random = Random();

  // Get random anime series
  static TvSeries? getRandomAnime(AnimeProvider provider) {
    final allSeries = provider.allSeries;
    if (allSeries.isEmpty) return null;
    return allSeries[_random.nextInt(allSeries.length)];
  }

  // Get random anime series with specific criteria
  static TvSeries? getRandomAnimeWithCriteria(
    AnimeProvider provider, {
    double? minRating,
    int? minEpisodes,
    String? genre,
  }) {
    var filteredSeries = provider.allSeries;

    if (minRating != null) {
      filteredSeries = filteredSeries
          .where((series) => series.voteAverage >= minRating)
          .toList();
    }

    if (minEpisodes != null) {
      filteredSeries = filteredSeries
          .where((series) => series.numberOfEpisodes >= minEpisodes)
          .toList();
    }

    if (genre != null) {
      filteredSeries = filteredSeries
          .where((series) => series.genres
              .any((g) => g.name.toLowerCase().contains(genre.toLowerCase())))
          .toList();
    }

    if (filteredSeries.isEmpty) return null;
    return filteredSeries[_random.nextInt(filteredSeries.length)];
  }

  // Get random anime poster URL
  static String? getRandomAnimePoster(AnimeProvider provider) {
    final randomSeries = getRandomAnime(provider);
    return randomSeries?.fullPosterUrl;
  }

  // Get random anime overview
  static String getRandomAnimeOverview(AnimeProvider provider) {
    final randomSeries = getRandomAnime(provider);
    return randomSeries?.overview ?? 'No overview available';
  }

  // Get random anime name
  static String getRandomAnimeName(AnimeProvider provider) {
    final randomSeries = getRandomAnime(provider);
    return randomSeries?.name ?? 'Unknown Anime';
  }

  // Get multiple random anime series
  static List<TvSeries> getMultipleRandomAnime(
      AnimeProvider provider, int count) {
    final allSeries = provider.allSeries;
    if (allSeries.isEmpty) return [];

    // Create a copy of the list to avoid modifying the original
    final availableSeries = List<TvSeries>.from(allSeries);
    final result = <TvSeries>[];

    // Ensure we don't try to get more items than available
    count = count.clamp(0, availableSeries.length);

    for (int i = 0; i < count; i++) {
      final randomIndex = _random.nextInt(availableSeries.length);
      result.add(availableSeries.removeAt(randomIndex));
    }

    return result;
  }
}
