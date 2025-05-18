// lib/screens/unisearch_screen.dart
import 'package:flutter/material.dart';
import 'package:miko/models/movie.dart' as m;
import 'package:miko/models/tv_series.dart' as ts;
import 'package:miko/models/tv_series_anime.dart' as tsa;
import 'package:miko/widgets/tv_series_card.dart';
//import 'package:miko/utils/dynamic_background.dart'; // Optional background
import 'package:provider/provider.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/utils/colors.dart';
import 'package:miko/widgets/movie_card.dart';
import 'package:miko/widgets/anime_series_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // Import for Timer (debouncing)
import 'package:miko/services/data_manager.dart'; // Import DataManager

// Assuming LoadingStatus enum exists in one of the providers or a common place
// If not, define it: enum LoadingStatus { initial, loading, loaded, error }

class UnifiedSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const UnifiedSearchScreen({this.initialQuery, super.key});

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final DataManager _dataManager = DataManager();
  Timer? _debounce;
  String _currentQuery = '';
  bool _isLoading = true;

  late MovieProvider _movieProvider;
  late TvSeriesProvider _tvProvider;
  late AnimeProvider _animeProvider;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _currentQuery = widget.initialQuery ?? '';
    _searchController.addListener(_onSearchChanged);
    
    // Properly initialize providers and load data

    _initializeProviders();
  }

  void _initializeProviders() {
    _movieProvider = Provider.of<MovieProvider>(context, listen: false);
    _tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);
    _animeProvider = Provider.of<AnimeProvider>(context, listen: false);

    _loadData().then((_) {
      if (_currentQuery.isNotEmpty) {
        _performSearch(_currentQuery, immediate: true);
      }
      _searchFocusNode.requestFocus();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _dataManager.ensureDataLoaded();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clear search state when leaving the screen
    _clearAllSearches();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      if (_searchController.text != _currentQuery) {
        _performSearch(_searchController.text);
      }
    });
  }

  void _performSearch(String query, {bool immediate = false}) {
    if (!mounted) return;

    setState(() {
      _currentQuery = query;
    });

    _movieProvider.searchMovies(query);
    _tvProvider.searchTvSeries(query);
    _animeProvider.searchAnime(query);
  }

  void _clearAllSearches() {
    _movieProvider.searchMovies('');
    _tvProvider.searchTvSeries('');
    _animeProvider.searchAnime('');
  }

  void _clearInputAndSearch() {
    setState(() {
      _currentQuery = '';
    });
    _searchController.clear();
    _clearAllSearches();
  }

  void _goBack() {
    _clearAllSearches();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final tvProvider = context.watch<TvSeriesProvider>();
    final animeProvider = context.watch<AnimeProvider>();

    // Combine all results
    final List<dynamic> allResults = [
      ...movieProvider.movies,
      ...tvProvider.seriesForDisplay,
      ...animeProvider.animeseriesForDisplay
    ];

    // Sort results by name
    allResults.sort((a, b) {
      String nameA = _getItemName(a);
      String nameB = _getItemName(b);
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    // Determine loading state
    final bool isLoading = _isLoading ||
        movieProvider.status == LoadingStatus.loading ||
        tvProvider.status == ts.LoadingStatus.loading ||
        animeProvider.status == tsa.LoadingStatus.loading;

    final bool hasResults = allResults.isNotEmpty;
    final bool hasSearched = _currentQuery.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.secondaryBackground.withOpacity(0.95),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.iconColor),
                      onPressed: _goBack,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(
                            color: AppColors.primaryText, fontSize: 18),
                        cursorColor: AppColors.accentColor,
                        decoration: InputDecoration(
                          hintText: 'Search Movies, TV & Anime...',
                          hintStyle: TextStyle(
                              color: AppColors.secondaryText.withOpacity(0.7)),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.secondaryText),
                                  onPressed: _clearInputAndSearch,
                                )
                              : null,
                        ),
                        onSubmitted: (query) =>
                            _performSearch(query, immediate: true),
                      ),
                    ),
                  ],
                ),
              ),

              // Results Area
              Expanded(
                child: _buildResultsArea(
                    isLoading, hasSearched, hasResults, allResults),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsArea(bool isLoading, bool hasSearched, bool hasResults,
      List<dynamic> results) {
    if (isLoading && !hasResults) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      );
    }

    if (!hasSearched) {
      return const Center(
        child: Text(
          'Start typing to search...',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    if (!isLoading && !hasResults && hasSearched) {
      return Center(
        child: Text(
          'No results found for "$_currentQuery"',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    // Display results in a grid
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 3,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    if (item is m.Movie) {
      return MovieCard(movie: item);
    } else if (item is ts.TvSeries) {
      return TvSeriesCard(series: item);
    } else if (item is tsa.TvSeriesAnime) {
      return AnimeSeriesCard(series: item);
    } else {
      return const SizedBox.shrink();
    }
  }

  String _getItemName(dynamic item) {
    if (item is m.Movie) {
      return item.title;
    } else if (item is tsa.TvSeriesAnime) {
      return item.name;
    } else if (item is ts.TvSeries) {
      return item.name;
    }
    return '';
  }
}
