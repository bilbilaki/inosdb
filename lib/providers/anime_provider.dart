// lib/providers/tv_series_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:myapp/models/episode.dart';
import 'package:myapp/models/season.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/services/tmdb_api_service.dart';
import 'package:myapp/services/cache_service.dart';

// Reusing LoadingStatus enum if defined elsewhere, otherwise define here
enum LoadingStatus { idle, loading, loaded, error }

class AnimeProvider extends ChangeNotifier {
 // Internal state
 Map<String, TvSeries> _seriesMap = {}; // Map<OriginalCsvName, TvSeriesObject>
 final Map<String, List<Episode>> _episodesBySeriesCsvName = {}; // Temporary storage for CSV data
 LoadingStatus _status = LoadingStatus.idle;
 String? _errorMessage;
 String _searchQuery = '';

 // External dependencies
 final TmdbApiService _apiService = TmdbApiService(); // Your TMDB service
 late final CacheService _cacheService;
 bool _isInitialized = false;

 // Public getters
 List<TvSeries> get allSeries => _seriesMap.values.toList()
 ..sort((a, b) => a.name.compareTo(b.name)); // Keep sorted

 List<TvSeries> get searchResults {
 if (_searchQuery.isEmpty) {
 return allSeries;
 } else {
 return _seriesMap.values.where((series) {
 final queryLower = _searchQuery.toLowerCase();
 return series.name.toLowerCase().contains(queryLower) ||
 series.overview.toLowerCase().contains(queryLower) ||
 series.genres.any((g) => g.name.toLowerCase().contains(queryLower)) ||
 series.firstAirDate?.contains(queryLower) == true; // Search by year maybe
 }).toList()
 ..sort((a, b) => a.name.compareTo(b.name));
 }
 }

 LoadingStatus get status => _status;
 String? get errorMessage => _errorMessage;
 bool get isLoading => _status == LoadingStatus.loading;
 bool get hasError => _status == LoadingStatus.error;
 String get searchQuery => _searchQuery;


 TvSeriesProvider() {
 _initializeProvider();
 }


 Future<void> _initializeProvider() async {
 if (_isInitialized) return;
 _cacheService = await CacheService.create();
 _isInitialized = true;
 loadAndProcessTvSeries();
 }


 Future<void> loadAndProcessTvSeries() async {
 if (_status == LoadingStatus.loading || !_isInitialized) return;

 _updateStatus(LoadingStatus.loading);
 _episodesBySeriesCsvName.clear(); // Clear previous CSV data
 _seriesMap.clear(); // Clear previous Series data

 try {
 // --- Step 1: Read and Parse CSV ---
 final rawCsvData = await rootBundle.loadString('assets/tvshow_db2.csv');
 List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawCsvData);

 final dataRows = csvTable.skip(1); // Skip header row

 for (final row in dataRows) {
 if (row.length >= 5) { // Ensure basic columns exist
 final String seriesNameCsv = row[0]?.toString().trim() ?? '';
 if (seriesNameCsv.isNotEmpty) {
 if (!_episodesBySeriesCsvName.containsKey(seriesNameCsv)) {
 _episodesBySeriesCsvName[seriesNameCsv] = [];
 }
 try {
 final episode = Episode.fromCsvInfo(seriesNameCsv, row);
 _episodesBySeriesCsvName[seriesNameCsv]!.add(episode);
 } catch (e) {
 if (kDebugMode) {
 print("Error parsing episode from row for series '$seriesNameCsv': $row -> $e");
 }
 // Optionally skip this row or handle error
 }
 }
 } else {
 if (kDebugMode) {
 print("Skipping invalid CSV row: $row");
 }
 }
 }

 if (kDebugMode) {
 print("Parsed ${_episodesBySeriesCsvName.length} unique series names from CSV.");
 _episodesBySeriesCsvName.forEach((key, value) {
 // print(" -> $key: ${value.length} episodes");
 });
 }

 // --- Step 2: Check cache and fetch new data ---
 final cachedSeriesNames = _cacheService.getCachedSeriesNames();
 List<Future<void>> fetchFutures = [];

 for (String seriesNameCsv in _episodesBySeriesCsvName.keys) {
 if (!cachedSeriesNames.contains(seriesNameCsv)) {
 // Only fetch from TMDB if not in cache
 fetchFutures.add(_fetchAndStoreTmdbDetails(seriesNameCsv));
 } else {
 // Use cached data
 final cachedData = _cacheService.getCachedTmdbData(seriesNameCsv);
 if (cachedData != null) {
 final baseTvSeries = TvSeries.fromTmdbJson(cachedData);
 _seriesMap[seriesNameCsv] = baseTvSeries;
 }
 }
 }

 // Wait for all new TMDB fetches to complete
 await Future.wait(fetchFutures);

 // --- Step 3: Combine TMDB data with CSV episode data ---
 _buildFinalSeriesList();

 // --- Finalize ---
 _updateStatus(LoadingStatus.loaded);
 if (kDebugMode) {
 print("Successfully loaded and processed ${_seriesMap.length} TV series.");
 }

 } catch (e, stacktrace) {
 _updateStatus(LoadingStatus.error, "Failed to load/process data: $e");
 if (kDebugMode) {
 print("TvSeriesProvider Error: $e");
 print(stacktrace);
 }
 _seriesMap.clear(); // Clear data on error
 _episodesBySeriesCsvName.clear();
 }
 }

 // Helper to fetch TMDB details for one series
 Future<void> _fetchAndStoreTmdbDetails(String seriesNameCsv) async {
 try {
 final tmdbSeriesJson = await _apiService.findAndFetchRawTvSeriesDetailsJson(seriesNameCsv);

 if (tmdbSeriesJson != null) {
 // Cache the TMDB data
 await _cacheService.cacheTmdbData(seriesNameCsv, tmdbSeriesJson);
 
 // Create TvSeries object
 final baseTvSeries = TvSeries.fromTmdbJson(tmdbSeriesJson);
 _seriesMap[seriesNameCsv] = baseTvSeries;
 
 if (kDebugMode) {
 print("Fetched and cached TMDB details for '$seriesNameCsv' (ID: ${baseTvSeries.tmdbId})");
 }
 }
 } catch (e) {
 if (kDebugMode) {
 print("Error fetching TMDB details for '$seriesNameCsv': $e");
 }
 // Handle fetch error - maybe log it, series might not appear
 }
 }


 // Helper to organize episodes into seasons and attach to TvSeries
 void _buildFinalSeriesList() {
 Map<String, TvSeries> finalMap = {};

 _episodesBySeriesCsvName.forEach((seriesNameCsv, csvEpisodes) {
 // Find the corresponding TMDB fetched series detail
 TvSeries? baseSeries = _seriesMap[seriesNameCsv];

 if (baseSeries != null) {
 // Group episodes by season number
 Map<int, List<Episode>> episodesBySeason = {};
 for (var episode in csvEpisodes) {
 if (!episodesBySeason.containsKey(episode.seasonNumber)) {
 episodesBySeason[episode.seasonNumber] = [];
 }
 episodesBySeason[episode.seasonNumber]!.add(episode);
 }

 // Create Season objects
 List<Season> seasons = episodesBySeason.entries.map((entry) {
 return Season(
 seasonNumber: entry.key,
 episodes: entry.value, // Episodes are already sorted within Season constructor
 );
 }).toList();

 // Create the final TvSeries object with combined data
 final finalSeries = baseSeries.copyWith(seasons: seasons);
 finalMap[seriesNameCsv] = finalSeries; // Store final combined object

 } else {
 if (kDebugMode) {
 print("Skipping series '$seriesNameCsv' in final build due to missing TMDB data.");
 }
 // Optionally, create a basic series object from CSV data only if needed
 }
 });

 _seriesMap = finalMap; // Replace the initial map with the final combined one
 // Now _seriesMap contains TvSeries objects with TMDB info and structured Season/Episode lists with URLs
 }


 void searchTvSeries(String query) {
 _searchQuery = query;
 notifyListeners(); // The getter 'searchResults' handles the filtering
 }

 // Function to get a TvSeries by its TMDB ID
 TvSeries? getTvSeriesByTmdbId(int tmdbId) {
 try {
 return _seriesMap.values.firstWhere((series) => series.tmdbId == tmdbId);
 } catch (e) {
 return null; // Not found
 }
 }

 // Helper to update status and notify listeners
 void _updateStatus(LoadingStatus newStatus, [String? message]) {
 _status = newStatus;
 _errorMessage = message;
 notifyListeners();
 }
}

// Modify TmdbApiService to add a raw JSON method if needed:
// Add this method inside TmdbApiService class
/*
 Future<Map<String, dynamic>?> findAndFetchRawTvSeriesDetailsJson(String seriesName) async {
 // ... (API key check, etc.) ...
 try {
 final searchUri = Uri.parse('$_baseUrl/search/tv?api_key=$_apiKey&query=${Uri.encodeComponent(seriesName)}');
 final searchResponse = await http.get(searchUri);

 if (searchResponse.statusCode == 200) {
 final searchData = json.decode(searchResponse.body) as Map<String, dynamic>;
 final results = searchData['results'] as List<dynamic>?;
 if (results != null && results.isNotEmpty) {
 final seriesId = (results[0] as Map<String, dynamic>)['id'] as int?;
 if (seriesId != null) {
 final detailsUri = Uri.parse('$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US');
 final detailsResponse = await http.get(detailsUri);
 if (detailsResponse.statusCode == 200) {
 return json.decode(detailsResponse.body) as Map<String, dynamic>;
 }
 }
 }
 }
 return null;
 } catch (e) {
 // ... (error handling) ...
 return null;
 }
 }
*/