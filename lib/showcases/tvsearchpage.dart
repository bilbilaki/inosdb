// --- tv_search_page.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'tv_model.dart'; // For TVSearchResponse and TVSearchResult
import 'movie_service.dart'; // Your service
import 'tv_detail_page.dart'; // To navigate to details

class TvSearchPage extends StatefulWidget {
  const TvSearchPage({Key? key}) : super(key: key);

  @override
  State<TvSearchPage> createState() => _TvSearchPageState();
}

class _TvSearchPageState extends State<TvSearchPage> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  TVSearchResponse? _searchResponse;
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';
  int _currentPage = 1;
  bool _isFetchingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    _movieService.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (_searchController.text.trim() != _currentQuery) {
        _currentQuery = _searchController.text.trim();
        _currentPage = 1; // Reset page for new search
        _searchResponse = null; // Clear previous results
        if (_currentQuery.isNotEmpty) {
          _fetchTvShows();
        } else {
          setState(() {
            _isLoading = false;
            _searchResponse = null;
            _error = null;
          });
        }
      }
    });
  }

  Future<void> _fetchTvShows({bool loadMore = false}) async {
    if (_currentQuery.isEmpty || _isFetchingMore) return;

    setState(() {
      if (loadMore) _isFetchingMore = true; else _isLoading = true;
      _error = null;
    });

    try {
      final response = await _movieService.searchTV(
        query: _currentQuery,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          if (loadMore) {
            _searchResponse?.results.addAll(response.results);
            // Update totalPages if necessary, though usually it's consistent
            _searchResponse = TVSearchResponse(
              page: response.page,
              results: _searchResponse?.results ?? response.results,
              totalPages: response.totalPages,
              totalResults: response.totalResults,
            );
          } else {
            _searchResponse = response;
          }
          if (loadMore) _isFetchingMore = false; else _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          if (loadMore) _isFetchingMore = false; else _isLoading = false;
        });
      }
    }
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && // near bottom
        !_isFetchingMore &&
        _searchResponse != null &&
        _currentPage < _searchResponse!.totalPages) {
      _currentPage++;
      _fetchTvShows(loadMore: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search TV Shows...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                 setState(() {
                    _currentQuery = '';
                    _searchResponse = null;
                    _isLoading = false;
                    _error = null;
                 });
              },
            )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && (_searchResponse == null || _searchResponse!.results.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_searchResponse == null && _currentQuery.isEmpty) {
        return const Center(child: Text('Start typing to search for TV shows.'));
    }
    if (_searchResponse == null || _searchResponse!.results.isEmpty) {
      return Center(child: Text('No results found for "$_currentQuery".'));
    }

    final results = _searchResponse!.results;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: results.length + (_isFetchingMore ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        if (index == results.length && _isFetchingMore) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
        }
        final tvResult = results[index];
        return _buildTvShowResultCard(context, tvResult);
      },
    );
  }

  Widget _buildTvShowResultCard(BuildContext context, TVSearchResult tvResult) {
    final String posterUrl = tvResult.posterPath != null
        ? 'https://inosdb.worker-inosuke.workers.dev/w500${tvResult.posterPath}'
        : 'https://via.placeholder.com/200x300?text=No+Image';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // We need a full TvShow object to navigate.
          // For now, let's pass a basic TvShow object created from TVSearchResult
          // Ideally, you'd fetch full details or have a way to construct it.
          final basicTvShow = TvShow( // Construct a basic TvShow
            id: tvResult.id,
            name: tvResult.name,
            originalName: tvResult.originalName,
            overview: tvResult.overview ?? '',
            posterPath: tvResult.posterPath,
            backdropPath: tvResult.backdropPath,
            voteAverage: tvResult.voteAverage,
            voteCount: tvResult.voteCount,
            firstAirDate: tvResult.firstAirDate,
            genreIds: tvResult.genreIds,
            originCountry: tvResult.originCountry,
            originalLanguage: tvResult.originalLanguage,
            adult: tvResult.adult,
            popularity: tvResult.popularity,
            // other fields can be null or default
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TvShowDetailPage(tvShow: basicTvShow)),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: Image.network(posterUrl, fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(color: Colors.grey[700], child: const Center(child: Icon(Icons.tv_outlined))),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tvResult.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (tvResult.firstAirDate != null && tvResult.firstAirDate!.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('First Aired: ${tvResult.formattedFirstAirDate}', style: Theme.of(context).textTheme.bodySmall),
                        ),
                    if (tvResult.voteAverage > 0)
                        Row(children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${tvResult.voteAverage.toStringAsFixed(1)} (${tvResult.voteCount})', style: Theme.of(context).textTheme.bodySmall),
                        ]),
                    const SizedBox(height: 8),
                    Text(
                      tvResult.truncatedOverview,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- END OF TvSearchPage.dart ---