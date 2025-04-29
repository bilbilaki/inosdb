// TODO Implement this library.// lib/providers/tv_series_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/episode_anime.dart';
import '../models/season_anime.dart';
import '../models/tv_series_anime.dart';

// Define enum outside the class if not already globally defined
// enum LoadingStatus { idle, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
  // --- Singleton Implementation ---
  static final AnimeProvider _instance = AnimeProvider._internal();

  factory AnimeProvider() {
    return _instance;
  }

  AnimeProvider._internal() {
    // Private constructor that is called only once
    _initializeData();
  }

  // --- Constants ---
  static const String _animeseriesDetailsCsvPath =
      'assets/anime_series_details.csv';
  static const String _episodesCsvPath = 'assets/anime_series_link.csv';

  // --- Private State ---
  Map<int, TvSeriesAnime> _animeseriesMap =
      {}; // Keyed by TMDB ID for efficient lookup
  List<TvSeriesAnime> _allAnimeSeriesList = []; // Sorted list for display
  List<TvSeriesAnime> _searchResults = [];
  LoadingStatus _status = LoadingStatus.idle;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isInitialized = false;

  // --- Public Getters ---
  List<TvSeriesAnime> get animeseriesForDisplay =>
      _searchQuery.isEmpty ? _allAnimeSeriesList : _searchResults;
  LoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoadingStatus.loading;
  bool get hasError => _status == LoadingStatus.error;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;

  // Initialize data only once
  Future<void> _initializeData() async {
    if (!_isInitialized) {
      await loadAnimeData();
      _isInitialized = true;
    }
  }

  // Ensure data is loaded before accessing
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeData();
    }
  }

  Future<void> loadAnimeData() async {
    if (_status == LoadingStatus.loading || _status == LoadingStatus.loaded)
      return;

    _updateStatus(LoadingStatus.loading);
    _animeseriesMap.clear();
    _allAnimeSeriesList.clear();
    _searchResults.clear();

    try {
      // 1. Load Series Details CSV
      final detailsRawData =
          await rootBundle.loadString(_animeseriesDetailsCsvPath);
      List<List<dynamic>> detailsCsvTable =
          const CsvToListConverter().convert(detailsRawData);

      final Map<int, TvSeriesAnime> tempAnimeSeriesMap = {};
      // Using a temporary map to store series names -> tmdb_id for linking episodes later
      final Map<String, int> animeseriesnameToTmdbidMap = {};

      for (final row in detailsCsvTable.skip(1)) {
        // Skip header row
        try {
          final animeseries = TvSeriesAnime.fromCsvRow(row);
          if (animeseries.tmdbId != 0) {
            // Use TMDB ID as the primary key
            tempAnimeSeriesMap[animeseries.tmdbId] = animeseries;
            // Store the mapping: case-insensitive name from details CSV to its TMDB ID
            animeseriesnameToTmdbidMap[animeseries.originalName
                .trim()
                .toLowerCase()] = animeseries.tmdbId;
            // Also map the potentially different 'series' name if it exists and differs
            if (row.length > 1 &&
                row[1] != null &&
                row[1].toString().trim().toLowerCase() !=
                    animeseries.originalName.trim().toLowerCase()) {
              animeseriesnameToTmdbidMap[
                  row[1].toString().trim().toLowerCase()] = animeseries.tmdbId;
            }
          } else {
            if (kDebugMode) {
              print(
                  "Skipping series due to missing or invalid TMDB ID in row: $row");
            }
          }
        } catch (e, stacktrace) {
          if (kDebugMode) {
            print("Error parsing TV Series details row: $row -> $e");
            print(stacktrace);
          }
          // Decide if you want to stop loading or just skip the row
        }
      }

      if (kDebugMode) {
        print(
            "Loaded ${tempAnimeSeriesMap.length} series details. Name mapping count: ${animeseriesnameToTmdbidMap.length}");
      }

      // 2. Load Episodes CSV
      final episodesRawData = await rootBundle.loadString(_episodesCsvPath);
      List<List<dynamic>> episodesCsvTable =
          const CsvToListConverter().convert(episodesRawData);

      // Group episodes temporarily by TMDB ID
      final Map<int, List<EpisodeAnime>> tempEpisodesByTmdbId = {};

      for (final row in episodesCsvTable.skip(1)) {
        // Skip header row
        if (row.isNotEmpty && row[0] != null) {
          final String animeseriesNameFromEpisodeCsv = row[0].toString().trim();
          final String animeseriesNameLower =
              animeseriesNameFromEpisodeCsv.toLowerCase();

          // *** IMPORTANT JOIN LOGIC ***
          // Attempt to find the TMDB ID using the name from the episode CSV
          int? targetTmdbId = animeseriesnameToTmdbidMap[animeseriesNameLower];

          if (targetTmdbId != null) {
            try {
              final episode = EpisodeAnime.fromCsvInfo(
                  animeseriesNameFromEpisodeCsv,
                  targetTmdbId,
                  row); // Pass targetTmdbId
              if (!tempEpisodesByTmdbId.containsKey(targetTmdbId)) {
                tempEpisodesByTmdbId[targetTmdbId] = [];
              }
              tempEpisodesByTmdbId[targetTmdbId]!.add(episode);
            } catch (e) {
              if (kDebugMode) {
                print(
                    "Error parsing episode from row for series '$animeseriesNameFromEpisodeCsv' (mapped to $targetTmdbId): $row -> $e");
              }
            }
          } else {
            // If the name wasn't found in the map
            if (kDebugMode) {
              // This indicates a mismatch or missing series in the details CSV
              print(
                  "Warning: Could not find matching TMDB ID for series name '$animeseriesNameFromEpisodeCsv' from episodes CSV.");
              // Optionally, try a fallback or log more prominently
            }
          }
        }
      }

      if (kDebugMode) {
        print("Processed episodes for ${tempEpisodesByTmdbId.length} series.");
      }

      // 3. Combine Details and Episodes
      for (final tmdbId in tempAnimeSeriesMap.keys) {
        final baseSeries = tempAnimeSeriesMap[tmdbId]!;
        final csvEpisodes =
            tempEpisodesByTmdbId[tmdbId] ?? []; // Get episodes for this TMDB ID

        // Sort episodes by season and episode number
        csvEpisodes.sort((a, b) {
          if (a.seasonNumber != b.seasonNumber) {
            return a.seasonNumber.compareTo(b.seasonNumber);
          }
          return a.episodeNumber.compareTo(b.episodeNumber);
        });

        // Group episodes by season number
        Map<int, List<EpisodeAnime>> episodesBySeason = {};
        for (var episode in csvEpisodes) {
          if (!episodesBySeason.containsKey(episode.seasonNumber)) {
            episodesBySeason[episode.seasonNumber] = [];
          }
          episodesBySeason[episode.seasonNumber]!.add(episode);
        }

        // Create Season objects and sort them
        List<SeasonAnime> seasons = episodesBySeason.entries
            .map((entry) => SeasonAnime(
                  seasonNumber: entry.key,
                  episodes: entry.value,
                ))
            .toList()
          ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

        // Create the final TvSeries object with combined data
        final finalSeries = baseSeries.copyWith(seasons: seasons);
        _animeseriesMap[tmdbId] = finalSeries; // Add to the final map
      }

      // Create the sorted list for display
      _allAnimeSeriesList = _animeseriesMap.values.toList()
        ..sort((a, b) => a.name
            .toLowerCase()
            .compareTo(b.name.toLowerCase())); // Case-insensitive sort

      _searchResults = _allAnimeSeriesList; // Initialize search results
      _updateStatus(LoadingStatus.loaded);
      _isInitialized = true;

      if (kDebugMode) {
        print(
            "Successfully loaded and combined data for ${_allAnimeSeriesList.length} TV series.");
      }
    } catch (e, stacktrace) {
      _updateStatus(LoadingStatus.error, "Failed to load TV series data: $e");
      if (kDebugMode) {
        print("TV Series Loading Error: $e");
        print(stacktrace);
      }
      _animeseriesMap = {};
      _allAnimeSeriesList = [];
      _searchResults = [];
      _isInitialized = false;
    }
  }

  void searchAnime(String query) {
    _searchQuery = query.toLowerCase().trim();
    if (_searchQuery.isEmpty) {
      _searchResults = _allAnimeSeriesList;
    } else {
      _searchResults = _allAnimeSeriesList.where((series) {
        // Adjust search logic based on available fields in TvSeries from CSV
        return series.name.toLowerCase().contains(_searchQuery) ||
            series.originalName.toLowerCase().contains(_searchQuery) ||
            series.overview.toLowerCase().contains(_searchQuery) ||
            series.genres.any((g) => g.toLowerCase().contains(_searchQuery)) ||
            series.keywords
                .any((k) => k.toLowerCase().contains(_searchQuery)) ||
            series.firstAirDate?.year.toString() ==
                _searchQuery || // Search by year
            series.tmdbId.toString() ==
                _searchQuery; // Allow searching by TMDB ID
      }).toList();
    }
    notifyListeners();
  }

  TvSeriesAnime? getAnimeByTmdbId(int tmdbId) {
    return _animeseriesMap[tmdbId]; // Direct lookup is efficient
  }

  void _updateStatus(LoadingStatus newStatus, [String? message]) {
    _status = newStatus;
    _errorMessage = message;
    notifyListeners();
  }
}
