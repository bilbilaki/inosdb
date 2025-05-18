// TODO Implement this library.
// lib/constants.dart
class AppConstants {
  // Custom TMDB Image Proxy Base URL
  static const String tmdbImageBaseUrl =
      'https://inosdb.worker-inosuke.workers.dev';
  static const String tmdbapitokens =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2MDdlNDBhZjViYjY2NTc2ZjZmZDcyNTJkNTUyOWUyNCIsIm5iZiI6MTcyNTMxNjQ1OC4yNCwic3ViIjoiNjZkNjNkNmEzZTFhYjQ1Y2U1YjFiN2NmIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.N701knycQaKNMmYbdRnF3ag0dl9i28cL4oZBC-c42OY';
  static const String tmdbapikey = '607e40af5bb66576f6fd7252d5529e24'; // Standard YouTube Base URLs
  static const String youtubeBaseUrl = 'https://www.youtube.com/watch?v=';
  static const String youtubeThumbnailBaseUrl =
      'https://img.youtube.com/vi/'; // For thumbnails

  // Asset paths (adjust if needed)
  static const String movieInfoPath = 'assets/data/movies_info.csv';
  static const String tvInfoPath = 'assets/data/tv_info.csv';
  static const String tvLinksPath = 'assets/data/tv_links.csv';
  static const String animeInfoPath = 'assets/anime_series_details.csv';
  static const String animeLinksPath = 'assets/anime_series_link.csv';

  // Image sizes
  static const String imageSizeW500 = 'w500';
  static const String imageSizeW780 = 'w780';
  static const String imageSizeW1280 = 'w1280';
  static const String imageSizeOriginal = 'original';
}
