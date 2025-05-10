// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Enum for theme preference
enum AppThemeMode { system, light, dark }

// Enum for grid layout preference
enum GridLayout { grid3x3, grid1x2, custom } // Add more as needed

class UserDataService extends ChangeNotifier {
  static const String _favoriteMoviesKey = 'favoriteMovies';
  static const String _favoriteTvSeriesKey = 'favoriteTvSeries';
  static const String _favoriteAnimeKey = 'favoriteAnime';
  static const String _watchlistMoviesKey = 'watchlistMovies';
  static const String _watchlistAnimeKey = 'watchlistAnime';
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

  List<int> get watchlistTvSeriesIds =>
      List.unmodifiable(_watchlistTvSeriesIds);

  // Default settings
  AppThemeMode _themeMode = AppThemeMode.system;
  GridLayout _homeGridLayout = GridLayout.grid3x3; // Example for home screen
  bool _useHardwareDecoder = true;
  bool _useSecondaryPlayer = false;
  String? _externalDownloadManagerPackage;
  String? _externalPlayerPackage;
  bool _areyouwantfarsi = false;
  // Default settings values
  String _externalPlayer = '';
  String _downloadManager = '';
  late double _gridSize; // Example: number of columns
  String _decoderPreference =
      'default'; // Example: 'default', 'hardware', 'software'
  // Getters
  AppThemeMode get themeMode => _themeMode;
  GridLayout get homeGridLayout => _homeGridLayout;
  bool get useHardwareDecoder => _useHardwareDecoder;
  bool get useSecondaryPlayer => _useSecondaryPlayer;
  String? get externalDownloadManagerPackage => _externalDownloadManagerPackage;
  String? get externalPlayerPackage => _externalPlayerPackage;
  bool get areyouwantfarsi => _areyouwantfarsi;
  // Getters for settings
  String get externalPlayer => _externalPlayer;
  String get downloadManager => _downloadManager;
  double get gridSize => _gridSize;
  String get decoderPreference => _decoderPreference;

  UserDataService() {
    _loadPreferences();
    _loadSettings();
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
  bool isFavoriteAnime(int animeId) => _favoriteAnimeIds.contains(animeId);
  bool isFavoriteTvSeries(int seriesId) =>
      _favoriteTvSeriesIds.contains(seriesId);

  Future<void> toggleFavoriteMovie(int movieId) async {
    isFavoriteMovie(movieId)
        ? _favoriteMovieIds.remove(movieId)
        : _favoriteMovieIds.add(movieId);
    await _setIntList(_favoriteMoviesKey, _favoriteMovieIds);
    notifyListeners();
  }

  Future<void> toggleFavoriteAnime(int animeId) async {
    isFavoriteAnime(animeId)
        ? _favoriteAnimeIds.remove(animeId)
        : _favoriteAnimeIds.add(animeId);
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
  bool isOnWatchlistAnime(int animeId) => _watchlistAnimeIds.contains(animeId);

  bool isOnWatchlistTvSeries(int seriesId) =>
      _watchlistTvSeriesIds.contains(seriesId);

  Future<void> toggleWatchlistMovie(int movieId) async {
    isOnWatchlistMovie(movieId)
        ? _watchlistMovieIds.remove(movieId)
        : _watchlistMovieIds.add(movieId);
    await _setIntList(_watchlistMoviesKey, _watchlistMovieIds);
    notifyListeners();
  }

  Future<void> toggleWatchlistAnime(int animeId) async {
    isOnWatchlistAnime(animeId)
        ? _watchlistAnimeIds.remove(animeId)
        : _watchlistAnimeIds.add(animeId);
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

    // Clear settings keys
    await _prefs?.remove('themeMode');
    await _prefs?.remove('homeGridLayout');
    await _prefs?.remove('useHardwareDecoder');
    await _prefs?.remove('useSecondaryPlayer');
    await _prefs?.remove('externalDownloadManagerPackage');
    await _prefs?.remove('externalPlayerPackage');

    // Clear new settings
    await _prefs?.remove('externalPlayer');
    await _prefs?.remove('downloadManager');
    await _prefs?.remove('gridSize');
    await _prefs?.remove('decoderPreference');
    await _prefs?.remove('areyouwantfarsi');

    // Reload settings to reset to defaults
    await _loadSettings();

    notifyListeners();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    // Load Theme Mode
    final themeModeIndex =
        _prefs?.getInt('themeMode') ?? AppThemeMode.system.index;
    _themeMode = AppThemeMode.values[themeModeIndex];

    // Load Home Grid Layout
    final homeGridLayoutIndex =
        _prefs?.getInt('homeGridLayout') ?? GridLayout.grid3x3.index;
    _homeGridLayout = GridLayout.values[homeGridLayoutIndex];

    // Load Player Settings
    _useHardwareDecoder = _prefs?.getBool('useHardwareDecoder') ?? true;
    _useSecondaryPlayer = _prefs?.getBool('useSecondaryPlayer') ?? false;
    _areyouwantfarsi = _prefs?.getBool('areyouwantfarsi') ?? false;

    // Load External App Packages
    _externalDownloadManagerPackage =
        _prefs?.getString('externalDownloadManagerPackage');
    _externalPlayerPackage = _prefs?.getString('externalPlayerPackage');

    // Load new settings
    _externalPlayer = _prefs?.getString('externalPlayer') ?? '';
    _downloadManager = _prefs?.getString('downloadManager') ?? '';
    _gridSize = _prefs?.getDouble('gridSize') ?? 3.0;
    _decoderPreference = _prefs?.getString('decoderPreference') ?? 'default';

    notifyListeners(); // Notify listeners after loading
  }

  // Save Theme Mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // Save Home Grid Layout
  Future<void> setHomeGridLayout(GridLayout layout) async {
    _homeGridLayout = layout;
    await _prefs?.setInt('homeGridLayout', layout.index);
    notifyListeners();
  }

  // Save Hardware Decoder setting
  Future<void> setUseHardwareDecoder(bool value) async {
    _useHardwareDecoder = value;
    await _prefs?.setBool('useHardwareDecoder', value);
    notifyListeners();
  }

  // Save Secondary Player setting
  Future<void> setUseSecondaryPlayer(bool value) async {
    _useSecondaryPlayer = value;
    await _prefs?.setBool('useSecondaryPlayer', value);
    notifyListeners();
  }

  Future<void> setAreuwanfarsi(bool value) async {
    _areyouwantfarsi = value;
    await _prefs?.setBool('areyouwantfarsi', value);
    notifyListeners();
  }

  // Save External Download Manager Package
  Future<void> setExternalDownloadManagerPackage(String? packageName) async {
    _externalDownloadManagerPackage = packageName;
    if (packageName == null || packageName.isEmpty) {
      await _prefs?.remove('externalDownloadManagerPackage');
    } else {
      await _prefs?.setString('externalDownloadManagerPackage', packageName);
    }
    notifyListeners();
  }

  // Save External Player Package
  Future<void> setExternalPlayerPackage(String? packageName) async {
    _externalPlayerPackage = packageName;
    if (packageName == null || packageName.isEmpty) {
      await _prefs?.remove('externalPlayerPackage');
    } else {
      await _prefs?.setString('externalPlayerPackage', packageName);
    }
    notifyListeners();
  }

  // Setters for settings
  Future<void> setExternalPlayer(String value) async {
    _externalPlayer = value;
    await _prefs?.setString('externalPlayer', value);
    notifyListeners();
  }

  Future<void> setDownloadManager(String value) async {
    _downloadManager = value;
    await _prefs?.setString('downloadManager', value);
    notifyListeners();
  }

  Future<void> setGridSize(double value) async {
    _gridSize = value;
    await _prefs?.setDouble('gridSize', value);
    notifyListeners();
  }

  Future<void> setDecoderPreference(String value) async {
    _decoderPreference = value;
    await _prefs?.setString('decoderPreference', value);
    notifyListeners();
  }
}
