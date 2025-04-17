/*import 'package:flutter/material.dart';
import 'package:myapp/utils/dynamic_background.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:searchfield/searchfield.dart';

class UnifiedSearchScreen extends StatefulWidget {
  const UnifiedSearchScreen({super.key});

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchFieldListItem<String>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).searchMovies('');
      Provider.of<TvSeriesProvider>(context, listen: false).searchTvSeries('');
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MovieProvider>(context, listen: false).searchMovies('');
        Provider.of<TvSeriesProvider>(context, listen: false)
            .searchTvSeries('');
      }
    });
    super.dispose();
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);

    // Combine movie and TV series suggestions
    final movieSuggestions = movieProvider.movies
        .where(
            (movie) => movie.title.toLowerCase().contains(query.toLowerCase()))
        .map((movie) => SearchFieldListItem<String>(
              movie.title,
              child: Text(
                movie.title,
                style: const TextStyle(color: AppColors.primaryText),
              ),
            ))
        .toList();

    /*  final tvSuggestions = tvProvider.searchResults
        .where((series) =>
            series.title.toLowerCase().contains(query.toLowerCase()))
        .map((series) => SearchFieldListItem<String>(
              series.title,
              child: Text(
                series.title,
                style: const TextStyle(color: AppColors.primaryText),
              ),
            ))
        .toList();

    setState(() {
      _suggestions = [...movieSuggestions, ...tvSuggestions];
    });
  }
*/
    void _performSearch(String query) {
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
      Provider.of<TvSeriesProvider>(context, listen: false)
          .searchTvSeries(query);
      _updateSuggestions(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DynamicBackground(
        theme: ParticlesTheme.dark,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: AppColors.secondaryBackground.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.iconColor),
                      onPressed: () {
                        _searchController.clear();
                        _UnifiedSearchScreenState._performSearch('');
                        _searchFocusNode.unfocus();
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: SearchField<String>(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        suggestions: _suggestions,
                        searchInputDecoration: SearchInputDecoration(
                          hintText: 'Search movies and TV series...',
                          hintStyle: TextStyle(
                              color: AppColors.secondaryText.withOpacity(0.7)),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.secondaryText),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch('');
                                    _searchFocusNode.requestFocus();
                                  },
                                )
                              : null,
                        ),
                        suggestionState: Suggestion.expand,
                        textInputAction: TextInputAction.search,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryBackground,
                        ),
                        suggestionStyle: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryBackground,
                        ),
                        onSearchTextChanged: _performSearch,
                        onSuggestionTap: (value) {
                          _searchController.text = value.item;
                          _performSearch(value.item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer2<MovieProvider, TvSeriesProvider>(
                  builder: (context, movieProvider, tvProvider, child) {
                    final query = movieProvider.searchQuery;

                    if (query.isEmpty) {
                      return const Center(
                        child: Text(
                          'Start typing to search...',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      );
                    }

                    if (movieProvider.status == LoadingStatus.loading ||
                        tvProvider.status == LoadingStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final movies = movieProvider.movies;
                    final tvSeries = tvProvider.searchResults;

                    if (movies.isEmpty && tvSeries.isEmpty) {
                      return Center(
                        child: Text(
                          'No results found for "$query"',
                          style:
                              const TextStyle(color: AppColors.secondaryText),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movies.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Movies',
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8.0),
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                return MovieCard(movie: movie);
                              },
                            ),
                          ],
                          if (tvSeries.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'TV Series',
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            MasonryGridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8.0),
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              itemCount: tvSeries.length,
                              itemBuilder: (context, index) {
                                final series = tvSeries[index];
                                return TvSeriesCard(series: series);
                              },
                            ),
                          ],
                        ],
                      ),
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
*/
