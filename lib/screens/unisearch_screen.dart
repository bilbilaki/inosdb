// lib/screens/unified_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:myapp/models/movie.dart' as m;
import 'package:myapp/models/tv_series.dart' as ts;
import 'package:myapp/models/tv_series_anime.dart' as tsa;
import 'package:myapp/utils/dynamic_background.dart'; // Optional background
import 'package:provider/provider.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:myapp/widgets/anime_series_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/router.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // Import for Timer (debouncing)

// Assuming LoadingStatus enum exists in one of the providers or a common place
// If not, define it: enum LoadingStatus { initial, loading, loaded, error }

class UnifiedSearchScreen extends StatefulWidget {
  final String? initialQuery;
  late String? query; // Optional initial query if needed
   UnifiedSearchScreen({this.initialQuery, this.query, super.key});

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  String? _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _currentQuery = widget.initialQuery ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear previous search results from providers if desired
      // Or trigger initial search if initialQuery is provided
      if (_currentQuery!.isNotEmpty) {
        _performSearch(_currentQuery!, immediate: true);
      } else {
        _clearAllSearches(); // Ensure results are clear on initial load if no query
      }
      _searchFocusNode.requestFocus();
    });

    // Listen to text changes for debouncing
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _currentQuery = '';
    _debounce?.cancel(); // Cancel timer if active
    _searchController.removeListener(_onSearchChanged); // Remove listener
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Clear search when leaving screen
    _clearAllSearches();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer( Duration(milliseconds: 500), () {
      // Adjust debounce duration (e.g., 500ms)
      if (_searchController.text != _currentQuery) {
        _performSearch(_searchController.text);
      }
    });
  }
late MovieProvider movieProvider;
late TvSeriesProvider tvProvider;
late AnimeProvider animeProvider;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  movieProvider = Provider.of<MovieProvider>(context, listen: false);
  tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);
  animeProvider = Provider.of<AnimeProvider>(context, listen: false);
}

  void _performSearch(String query, {bool immediate = false}) {
  _currentQuery = query;

  movieProvider.searchMovies(query);
  tvProvider.searchTvSeries(query);
  animeProvider.searchAnime(query);
}


  void _clearAllSearches() {
    // Use listen: false as we're triggering actions

    _currentQuery = '';
  }

  void _clearInputAndSearch() {
    setState(() {
      _currentQuery = '';
    });
    _searchController.clear();
    // Perform search immediately with empty query to clear results
    // _performSearch('', immediate: true);
    // _searchFocusNode.requestFocus(); // Keep focus
  }

  void _goBack() {
    setState(() {
      _currentQuery = '';
    });
    // Clear search when explicitly navigating back
    _clearAllSearches();
    _searchController.clear(); // Clear text field
    _searchFocusNode.unfocus(); // Remove focus
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch<Provider>() or Provider.of<Provider>(context)
    // inside the build method to listen for changes and rebuild the UI.
    final movieProvider = context.watch<MovieProvider>();
    final tvProvider = context.watch<TvSeriesProvider>();
    final animeProvider = context.watch<AnimeProvider>();

    // Combine results
    final List<dynamic> allResults = [
      ...movieProvider
          .movies, // Assuming 'movies' holds search results in MovieProvider
      ...tvProvider
          .seriesForDisplay, // Assuming 'seriesForDisplay' holds search results
      ...animeProvider
          .animeseriesForDisplay // Assuming 'animeseriesForDisplay' holds search results
    ];

    // Optional: Sort combined results alphabetically by title/name
    allResults.sort((a, b) {
      String nameA = _getItemName(a);
      String nameB = _getItemName(b);
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    // Determine loading state
    final bool isLoading = movieProvider.status == LoadingStatus.loading ||
        tvProvider.status == ts.LoadingStatus.loading ||
        animeProvider.status == tsa.LoadingStatus.loading;

    // Determine if there are any results
    final bool hasResults = allResults.isNotEmpty;
    final bool hasSearched = _currentQuery!.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        // Wrap with DynamicBackground
        body: DynamicBackground(
          theme: ParticlesTheme.dark,
          child: SafeArea(
            child: Column(
              children: [
                // --- Search AppBar ---
                Container(
                  color: AppColors.secondaryBackground
                      .withOpacity(0.95), // Slightly opaque
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.iconColor),
                        onPressed: _goBack, // Use specific back function
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          // autofocus: true, // Already handled in initState
                          style: const TextStyle(
                              color: AppColors.primaryText, fontSize: 18),
                          cursorColor: AppColors.accentColor,
                          decoration: InputDecoration(
                            hintText:
                                'Search Movies, TV & Anime...', // Updated hint
                            hintStyle: TextStyle(
                                color:
                                    AppColors.secondaryText.withOpacity(0.7)),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: AppColors.secondaryText),
                                    onPressed:
                                        _clearInputAndSearch, // Use specific clear function
                                  )
                                : null,
                          ),
                          // onChanged handled by listener (_onSearchChanged)
                          onSubmitted: (query) => _performSearch(query,
                              immediate: true), // Search immediately on submit
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Search Results ---
                Expanded(
                  child: _buildResultsArea(
                      isLoading, hasSearched, hasResults, allResults),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the results area based on state
  Widget _buildResultsArea(bool isLoading, bool hasSearched, bool hasResults,
      List<dynamic> results) {
    if (!hasSearched) {
      return const Center(
          child: Text('Start typing to search...',
              style: TextStyle(color: AppColors.secondaryText)));
    }

    if (isLoading && !hasResults) {
      // Show loading only if there are no results yet from previous search
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accentColor));
    }

    if (!isLoading && !hasResults && hasSearched) {
      return Center(
          child: Text('No results found for "$_currentQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText)));
    }

    // Display results using MasonryGridView
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 3, // Adjust columns
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        // Return the appropriate card based on the item type
        return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
              enableReverse: true, // Optional: enable reverse tilt
            ),
            child: _buildItemCard(item) // Use helper to build card
            );
      },
    );
  }

  // Helper function to get the correct card widget
  Widget _buildItemCard(dynamic item) {
    if (item is m.Movie) {
      return MovieCard(movie: item);
    } else if (item is ts.TvSeries) {
      return TvSeriesCard(series: item);
    } else if (item is tsa.TvSeriesAnime) {
      return AnimeSeriesCard(series: item);
    } else {
      // Should not happen with current logic, but good practice
      return const SizedBox.shrink();
    }
  }

  // Helper function to get name/title for sorting
  String _getItemName(dynamic item) {
    if (item is m.Movie) {
      return item.title;
    } else if (item is tsa.TvSeriesAnime) {
      return item.name;
    } else if (item is ts.TvSeries) {
      return item.name;
    }
    return ''; // Default empty string if type is unknown
  }
}
