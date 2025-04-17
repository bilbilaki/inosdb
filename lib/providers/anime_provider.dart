// lib/providers/tv_series_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:myapp/models/episode.dart';
import 'package:myapp/models/season.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/services/tmdb_api_service.dart';
import 'package:myapp/services/cache_service.dart';

enum LoadingStatus { idle, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
  // Internal state
  final Map<String, TvSeries> _seriesMap = {};
  final Map<String, List<Episode>> _episodesBySeriesCsvName = {};
  LoadingStatus _status = LoadingStatus.idle;
  String? _errorMessage;
  String _searchQuery = '';

  // Pagination and lazy loading
  static const int _batchSize = 40;
  int _currentBatch = 0;
  bool _hasMoreData = true;
  List<String> _allSeriesNames = [];

  // External dependencies
  final TmdbApiService _apiService = TmdbApiService();
  late final CacheService _cacheService;
  bool _isInitialized = false;

  // Public getters
  List<TvSeries> get allSeries =>
      _seriesMap.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  List<TvSeries> get searchResults {
    if (_searchQuery.isEmpty) {
      return allSeries;
    } else {
      return _seriesMap.values.where((series) {
        final queryLower = _searchQuery.toLowerCase();
        return series.name.toLowerCase().contains(queryLower) ||
            series.overview.toLowerCase().contains(queryLower) ||
            series.genres
                .any((g) => g.name.toLowerCase().contains(queryLower)) ||
            series.firstAirDate?.contains(queryLower) == true;
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  LoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoadingStatus.loading;
  bool get hasError => _status == LoadingStatus.error;
  String get searchQuery => _searchQuery;
  bool get hasMoreData => _hasMoreData;

  AnimeProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    if (_isInitialized) return;
    _cacheService = await CacheService.create();
    _isInitialized = true;
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load CSV data first
      final rawCsvData = await rootBundle.loadString('assets/tvshow_db2.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawCsvData);

      // Clear previous data
      _episodesBySeriesCsvName.clear();
      _allSeriesNames.clear();

      // Process CSV data
      for (final row in csvTable.skip(1)) {
        if (row.length >= 5) {
          final String seriesNameCsv = row[0]?.toString().trim() ?? '';
          if (seriesNameCsv.isNotEmpty) {
            if (!_episodesBySeriesCsvName.containsKey(seriesNameCsv)) {
              _episodesBySeriesCsvName[seriesNameCsv] = [];
              _allSeriesNames.add(seriesNameCsv);
            }
            try {
              final episode = Episode.fromCsvInfo(seriesNameCsv, row);
              // Only add valid episodes
              _episodesBySeriesCsvName[seriesNameCsv]!.add(episode);
                        } catch (e) {
              if (kDebugMode) {
                print(
                    "Error parsing episode from row for series '$seriesNameCsv': $row -> $e");
              }
            }
          }
        }
      }

      // Remove duplicates from series names
      _allSeriesNames = _allSeriesNames.toSet().toList();

      // Load first batch of TMDB data
      await loadNextBatch();
    } catch (e) {
      _updateStatus(LoadingStatus.error, "Failed to load initial data: $e");
    }
  }

  Future<void> loadNextBatch() async {
    if (_status == LoadingStatus.loading || !_isInitialized || !_hasMoreData) {
      return;
    }

    _updateStatus(LoadingStatus.loading);

    try {
      final startIndex = _currentBatch * _batchSize;
      final endIndex =
          (startIndex + _batchSize).clamp(0, _allSeriesNames.length);

      if (startIndex >= _allSeriesNames.length) {
        _hasMoreData = false;
        _updateStatus(LoadingStatus.loaded);
        return;
      }

      final batchSeriesNames = _allSeriesNames.sublist(startIndex, endIndex);
      List<Future<void>> fetchFutures = [];

      for (String seriesNameCsv in batchSeriesNames) {
        if (!_seriesMap.containsKey(seriesNameCsv)) {
          final cachedData = _cacheService.getCachedTmdbData(seriesNameCsv);
          if (cachedData != null) {
            _processSeriesData(seriesNameCsv, cachedData);
          } else {
            fetchFutures.add(_fetchAndStoreTmdbDetails(seriesNameCsv));
          }
        }
      }

      await Future.wait(fetchFutures);
      _currentBatch++;
      _updateStatus(LoadingStatus.loaded);
    } catch (e) {
      _updateStatus(LoadingStatus.error, "Failed to load batch: $e");
    }
  }

  void _processSeriesData(String seriesNameCsv, Map<String, dynamic> tmdbData) {
    final baseTvSeries = TvSeries.fromTmdbJson(tmdbData);

    // Get episodes from CSV
    final csvEpisodes = _episodesBySeriesCsvName[seriesNameCsv] ?? [];

    // Sort episodes by season and episode number
    csvEpisodes.sort((a, b) {
      if (a.seasonNumber != b.seasonNumber) {
        return a.seasonNumber.compareTo(b.seasonNumber);
      }
      return a.episodeNumber.compareTo(b.episodeNumber);
    });

    // Group episodes by season
    Map<int, List<Episode>> episodesBySeason = {};
    for (var episode in csvEpisodes) {
      if (!episodesBySeason.containsKey(episode.seasonNumber)) {
        episodesBySeason[episode.seasonNumber] = [];
      }
      episodesBySeason[episode.seasonNumber]!.add(episode);
    }

    // Create Season objects and sort them
    List<Season> seasons = episodesBySeason.entries
        .map((entry) => Season(
              seasonNumber: entry.key,
              episodes: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    // Create final TvSeries with combined data
    final finalSeries = baseTvSeries.copyWith(seasons: seasons);
    _seriesMap[seriesNameCsv] = finalSeries;
  }

  Future<void> _fetchAndStoreTmdbDetails(String seriesNameCsv) async {
    try {
      final tmdbSeriesJson =
          await _apiService.findAndFetchRawTvSeriesDetailsJsonpostscreen(seriesNameCsv);
      if (tmdbSeriesJson != null) {
        await _cacheService.cacheTmdbData(seriesNameCsv, tmdbSeriesJson);
        _processSeriesData(seriesNameCsv, tmdbSeriesJson);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching TMDB details for '$seriesNameCsv': $e");
      }
    }
  }

  void searchTvSeries(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  TvSeries? getTvSeriesByTmdbId(int tmdbId) {
    try {
      return _seriesMap.values.firstWhere((series) => series.tmdbId == tmdbId);
    } catch (e) {
      return null;
    }
  }

  void _updateStatus(LoadingStatus newStatus, [String? message]) {
    _status = newStatus;
    _errorMessage = message;
    notifyListeners();
  }
}
