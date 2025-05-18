// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
//import 'package:myapp/utils/dynamic_background.dart';
import 'package:provider/provider.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/utils/colors.dart';
import 'package:miko/widgets/movie_card.dart'; // Reuse MovieCard
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/router.dart';
import 'package:go_router/go_router.dart';
// Import the original Movie model if needed for type hints,
// but the provider should handle the type correctly.
// import '../models/movie.dart';

class SearchScreen extends StatefulWidget {
  final String? query;
  const SearchScreen({this.query, super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Optionally clear search when entering screen or focus input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear previous search results from provider if needed
      Provider.of<MovieProvider>(context, listen: false).searchMovies('');
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Optional: Clear search when leaving screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if widget is still in the tree
        Provider.of<MovieProvider>(context, listen: false).searchMovies('');
      }
    });
    super.dispose();
  }

  void _performSearch(BuildContext context, String query) {
    if (query.isNotEmpty) {
      // Call the search method on the provider
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider for state changes
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      // Wrap with DynamicBackground
      body: SafeArea(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar section
              Container(
                color: AppColors.secondaryBackground,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.iconColor),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Provider.of<MovieProvider>(context, listen: false)
                            .searchMovies('');
                        _searchController.clear();
                        _searchFocusNode.unfocus(); // Remove focus
                      },
                    ),
                    // Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true, // Focus the field immediately
                        style: const TextStyle(
                            color: AppColors.primaryText, fontSize: 18),
                        cursorColor: AppColors.accentColor,
                        decoration: InputDecoration(
                          hintText: 'Search movies...',
                          hintStyle: TextStyle(
                              color: AppColors.secondaryText.withOpacity(0.7)),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.secondaryText),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch(
                                        context, ''); // Clear results
                                    _searchFocusNode
                                        .requestFocus(); // Keep focus
                                  },
                                )
                              : null,
                        ),
                        onChanged: (query) => _performSearch(context,
                            query), // Search as user types (can add debounce later)
                        onSubmitted: (query) {
                          _performSearch(context, query);
                        }, // Also search on submit
                      ),
                    ),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: Consumer<MovieProvider>(
                  builder: (context, movieProvider, child) {
                    // Show results only when query is not empty
                    if (movieProvider.searchQuery.isEmpty) {
                      return const Center(
                          child: Text('Start typing to search...',
                              style:
                                  TextStyle(color: AppColors.secondaryText)));
                    }

                    // Show loading indicator if search is in progress (if async search was implemented)
                    if (movieProvider.status == LoadingStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (movieProvider.movies.isEmpty) {
                      return Center(
                          child: Text(
                              'No results found for "${movieProvider.searchQuery}"',
                              style: const TextStyle(
                                  color: AppColors.secondaryText)));
                    }

                    // Display results using a Grid (same as home screen)
                    return MasonryGridView.count(
                      padding: const EdgeInsets.all(8.0),
                      crossAxisCount: 3, // Adjust number of columns
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      itemCount: movieProvider.movies.length,
                      itemBuilder: (context, index) {
                        final movie = movieProvider
                            .movies[index]; // This is now app_movie.Movie
                        return MovieCard(
                            movie:
                                movie); // MovieCard should expect app_movie.Movie
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
