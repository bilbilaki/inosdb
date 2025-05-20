// movie_search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'movie_model.dart'; // Assuming you have a similar model structure
import 'movie_service.dart';
import 'movie_detail_page.dart';

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({Key? key}) : super(key: key);

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  SearchResponse? _searchResponse;
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
          _fetchMovies();
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

  Future<void> _fetchMovies({bool loadMore = false}) async {
    if (_currentQuery.isEmpty || _isFetchingMore) return;

    setState(() {
      if (loadMore) _isFetchingMore = true; else _isLoading = true;
      _error = null;
    });

    try {
      final response = await _movieService.searchMovies(
        query: _currentQuery,
        page: _currentPage,
      );
      
      if (mounted) {
        setState(() {
          if (loadMore) {
            _searchResponse?.results.addAll(response.results);
            _searchResponse = SearchResponse(
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && 
        !_isFetchingMore &&
        _searchResponse != null &&
        _currentPage < _searchResponse!.totalPages) {
      _currentPage++;
      _fetchMovies(loadMore: true);
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
            hintText: 'Search Movies...',
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
      return const Center(child: Text('Start typing to search for movies.'));
    }
    
    if (_searchResponse == null || _searchResponse!.results.isEmpty) {
      return Center(child: Text('No results found for "$_currentQuery".'));
    }

    final results = _searchResponse!.results;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: results.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length && _isFetchingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0), 
              child: CircularProgressIndicator()
            )
          );
        }
        
        final movie = results[index];
        return _buildMovieResultCard(context, movie);
      },
    );
  }

  Widget _buildMovieResultCard(BuildContext context, Movie movie) {
    final String posterUrl = movie.posterPath != null
      ? 'https://inosdb.worker-inosuke.workers.dev/w500${movie.posterPath}'
      : 'https://via.placeholder.com/200x300?text=No+Image';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(movie: movie)
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: Image.network(
                posterUrl, 
                fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(
                  color: Colors.grey[700], 
                  child: const Center(child: Icon(Icons.movie_outlined))
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title, 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Released: ${movie.releaseDate}', 
                          style: Theme.of(context).textTheme.bodySmall
                        ),
                      ),
                    if (movie.voteAverage > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)} (${movie.voteCount})', 
                            style: Theme.of(context).textTheme.bodySmall
                          ),
                        ]
                      ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview ?? '',
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