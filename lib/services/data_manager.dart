import 'package:flutter/foundation.dart';
import '../providers/anime_provider.dart';
import '../providers/movie_provider.dart';
// Import other providers as needed

enum DataLoadingStatus { notStarted, loading, completed, error }

class DataManager {
  // Singleton implementation
  static final DataManager _instance = DataManager._internal();
  
  factory DataManager() {
    return _instance;
  }
  
  DataManager._internal();
  
  // Providers
  final AnimeProvider animeProvider = AnimeProvider();
  final MovieProvider movieProvider = MovieProvider();
  // Add other providers as needed
  
  // Status tracking
  DataLoadingStatus _status = DataLoadingStatus.notStarted;
  String? _errorMessage;
  
  // Getters
  DataLoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DataLoadingStatus.loading;
  bool get isInitialized => _status == DataLoadingStatus.completed;
  
  // Initialize all data sources
  Future<void> initializeAllData() async {
    if (_status == DataLoadingStatus.loading || _status == DataLoadingStatus.completed) {
      return;
    }
    
    _status = DataLoadingStatus.loading;
    
    try {
      // Initialize providers in parallel
      await Future.wait([
        animeProvider.ensureInitialized(),
        movieProvider.ensureInitialized(),
        // Add other providers as needed
      ]);
      
      _status = DataLoadingStatus.completed;
      if (kDebugMode) {
        print("All data sources initialized successfully");
      }
    } catch (e) {
      _status = DataLoadingStatus.error;
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("Error initializing data sources: $e");
      }
    }
  }
  
  // Method to ensure data is loaded before accessing
  Future<void> ensureDataLoaded() async {
    if (_status != DataLoadingStatus.completed) {
      await initializeAllData();
    }
  }
} 