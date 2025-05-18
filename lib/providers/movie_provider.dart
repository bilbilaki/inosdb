// TODO Implement this library.// lib/providers/movie_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/movie.dart';

enum LoadingStatus { idle, loading, loaded, error }

class MovieProvider extends ChangeNotifier {
  // --- Singleton Implementation ---
  static final MovieProvider _instance = MovieProvider._internal();

  factory MovieProvider() {
    return _instance;
  }

  MovieProvider._internal() {
    // Private constructor that is called only once
    _initializeData();
  }

  List<Movie> _movies = [];
  List<Movie> _searchResults = [];
  LoadingStatus _status = LoadingStatus.idle;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isInitialized = false;

  List<Movie> get movies => _searchQuery.isEmpty ? _movies : _searchResults;
  LoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoadingStatus.loading;
  bool get hasError => _status == LoadingStatus.error;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;

  Future<void> _initializeData() async {
    if (!_isInitialized) {
      await loadMovies();
      _isInitialized = true;
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeData();
    }
  }

  Future<void> loadMovies() async {
    if (_status == LoadingStatus.loading || _status == LoadingStatus.loaded)
      return; // Prevent multiple loads
    _searchQuery = '';
    _status = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawData = await rootBundle.loadString('assets/movies_db.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawData);

      // Make sure you are processing ALL rows, not just the first one.
      // If your CSV has a header row, you might need to skip it (e.g., .skip(1))
      final dataRows = csvTable.skip(1); // Example: Skip header row

      // Ensure the .map() processes all 'dataRows' and .toList() collects them all.
      _movies = dataRows.map((row) {
        // Replace with your actual Movie object creation based on CSV columns
        return Movie.fromCsvRow(row);
      }).toList(); // This should create a list of ALL movies from the CSV rows processed.

      _status = LoadingStatus.loaded;
      if (kDebugMode) {
        print("Successfully loaded ${_movies.length} movies from CSV.");
      }
    } catch (e, stacktrace) {
      _status = LoadingStatus.error;
      _errorMessage = "Failed to load or parse CSV: $e";
      if (kDebugMode) {
        print("CSV Loading Error: $e");
        print(stacktrace);
      }
      _movies = []; // Clear movies on error
    } finally {
      _searchResults = _movies; // Initialize search results
      notifyListeners();
    }
  }

  void searchMovies(String? query) {
    _searchQuery = query?.toLowerCase().trim() ?? '';
    if (_searchQuery.isEmpty) {
      _searchResults = _movies; // Show all if query is empty
    } else {
      _searchResults = _movies.where((movie) {
        // Search logic: check title, original title, overview, genres, keywords
        // Add more fields as needed (actors would require parsing 'cast' if available)
        return movie.title.toLowerCase().contains(_searchQuery) ||
            movie.originalTitle.toLowerCase().contains(_searchQuery) ||
            movie.overview.toLowerCase().contains(_searchQuery) ||
            movie.genres.any((g) => g.toLowerCase().contains(_searchQuery)) ||
            movie.keywords.any((k) => k.toLowerCase().contains(_searchQuery)) ||
            movie.releaseDate?.year.toString() ==
                _searchQuery; // Allow searching by year
      }).toList();
    }
  }

  // Function to get a movie by its ID (useful for detail pages)
  Movie? getMovieById(int id) {
    try {
      return _movies.firstWhere((movie) => movie.id == id);
      
    } catch (e) {
      return null; // Not found
    }
  }
      notifyListeners();

}
