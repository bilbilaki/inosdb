// TODO Implement this library.
// lib/services/user_data_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService extends ChangeNotifier {
  static const String _favoriteMoviesKey = 'favoriteMovies';
  static const String _favoriteTvSeriesKey = 'favoriteTvSeries';
  static const String _favoriteAnimeKey = 'favoriteTvSeries';
  static const String _watchlistMoviesKey = 'watchlistMovies';
  static const String _watchlistAnimeKey = 'watchlistMovies';
  static const String _watchlistTvSeriesKey = 'watchlistTvSeries';
  // Add keys for history, downloads if implemented later

  SharedPreferences? _prefs;

  List<int> _favoriteMovieIds = [];
  List<int> _favoriteAnimeIds = [];
  List<int> _favoriteTvSeriesIds = [];
  List<int> _watchlistMovieIds = [];
  List<int> _watchlistAnimeIds = [];

  List<int> _watchlistTvSeriesIds = [];

  List<int> get favoriteMovieIds => List.unmodifiable(_favoriteMovieIds);
  List<int> get favoriteAnimeIds => List.unmodifiable(_favoriteAnimeIds);
  List<int> get favoriteTvSeriesIds => List.unmodifiable(_favoriteTvSeriesIds);
  List<int> get watchlistMovieIds => List.unmodifiable(_watchlistMovieIds);
  List<int> get watchlistAnimeIds => List.unmodifiable(_watchlistAnimeIds);

  List<int> get watchlistTvSeriesIds => List.unmodifiable(_watchlistTvSeriesIds);

  UserDataService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _favoriteMovieIds = _getIntList(_favoriteMoviesKey);
    _favoriteAnimeIds = _getIntList(_favoriteAnimeKey);
    _favoriteTvSeriesIds = _getIntList(_favoriteTvSeriesKey);
    _watchlistMovieIds = _getIntList(_watchlistMoviesKey);
    _watchlistAnimeIds = _getIntList(_watchlistAnimeKey);
    _watchlistTvSeriesIds = _getIntList(_watchlistTvSeriesKey);
    notifyListeners(); // Notify listeners once prefs are loaded
  }

  List<int> _getIntList(String key) {
    final List<String>? stringList = _prefs?.getStringList(key);
    if (stringList == null) return [];
    return stringList.map((id) => int.tryParse(id)).whereType<int>().toList();
  }

  Future<void> _setIntList(String key, List<int> list) async {
    await _prefs?.setStringList(key, list.map((id) => id.toString()).toList());
  }

  // --- Favorites ---
  bool isFavoriteMovie(int movieId) => _favoriteMovieIds.contains(movieId);
  bool isFavoriteAnime(int animeId) => _favoriteMovieIds.contains(animeId);
  bool isFavoriteTvSeries(int seriesId) => _favoriteTvSeriesIds.contains(seriesId);

  Future<void> toggleFavoriteMovie(int movieId) async {
    isFavoriteMovie(movieId)
        ? _favoriteMovieIds.remove(movieId)
        : _favoriteMovieIds.add(movieId);
    await _setIntList(_favoriteMoviesKey, _favoriteMovieIds);
    notifyListeners();
  }
    Future<void> toggleFavoriteAnime(int animeId) async {
    isFavoriteMovie(animeId)
        ? _favoriteMovieIds.remove(animeId)
        : _favoriteMovieIds.add(animeId);
    await _setIntList(_favoriteAnimeKey, _favoriteAnimeIds);
    notifyListeners();
  }

  Future<void> toggleFavoriteTvSeries(int seriesId) async {
    isFavoriteTvSeries(seriesId)
        ? _favoriteTvSeriesIds.remove(seriesId)
        : _favoriteTvSeriesIds.add(seriesId);
    await _setIntList(_favoriteTvSeriesKey, _favoriteTvSeriesIds);
    notifyListeners();
  }

  // --- Watchlist ---
   bool isOnWatchlistMovie(int movieId) => _watchlistMovieIds.contains(movieId);
  bool isOnWatchlistAnime(int animeId) => _watchlistMovieIds.contains(animeId);

   bool isOnWatchlistTvSeries(int seriesId) => _watchlistTvSeriesIds.contains(seriesId);

  Future<void> toggleWatchlistMovie(int movieId) async {
    isOnWatchlistMovie(movieId)
        ? _watchlistMovieIds.remove(movieId)
        : _watchlistMovieIds.add(movieId);
    await _setIntList(_watchlistMoviesKey, _watchlistMovieIds);
    notifyListeners();
  }
Future<void> toggleWatchlistAnime(int animeId) async {
    isOnWatchlistMovie(animeId)
        ? _watchlistMovieIds.remove(animeId)
        : _watchlistMovieIds.add(animeId);
    await _setIntList(_watchlistAnimeKey, _watchlistAnimeIds);
    notifyListeners();
  }
   Future<void> toggleWatchlistTvSeries(int seriesId) async {
    isOnWatchlistTvSeries(seriesId)
        ? _watchlistTvSeriesIds.remove(seriesId)
        : _watchlistTvSeriesIds.add(seriesId);
    await _setIntList(_watchlistTvSeriesKey, _watchlistTvSeriesIds);
    notifyListeners();
  }

  // --- Clear All (Optional - useful for debugging/settings) ---
  Future<void> clearAllUserData() async {
      _favoriteMovieIds.clear();
       _favoriteAnimeIds.clear();

      _favoriteTvSeriesIds.clear();
      _watchlistMovieIds.clear();
            _watchlistAnimeIds.clear();

      _watchlistTvSeriesIds.clear();
      await _prefs?.remove(_favoriteMoviesKey);
            await _prefs?.remove(_favoriteAnimeKey);

      await _prefs?.remove(_favoriteTvSeriesKey);
      await _prefs?.remove(_watchlistMoviesKey);
            await _prefs?.remove(_watchlistAnimeKey);

      await _prefs?.remove(_watchlistTvSeriesKey);
      notifyListeners();
  }
}