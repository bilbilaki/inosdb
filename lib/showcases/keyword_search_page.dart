// keyword_search_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'movie_service.dart';
import 'movie_model.dart';
import 'movie_detail_page.dart';

class KeywordSearchPage extends StatefulWidget {
  const KeywordSearchPage({Key? key}) : super(key: key);

  @override
  State<KeywordSearchPage> createState() => _KeywordSearchPageState();
}

class _KeywordSearchPageState extends State<KeywordSearchPage> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  KeywordSearchResponse? _keywordSearchResponse;
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
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (_searchController.text.trim() != _currentQuery) {
        _currentQuery = _searchController.text.trim();
        _currentPage = 1;
        _keywordSearchResponse = null;
        if (_currentQuery.isNotEmpty) {
          _fetchKeywords();
        } else {
          setState(() {
            _isLoading = false;
            _keywordSearchResponse = null;
            _error = null;
          });
        }
      }
    });
  }

  Future<void> _fetchKeywords({bool loadMore = false}) async {
    if (_currentQuery.isEmpty || _isFetchingMore) return;

    setState(() {
      if (loadMore) _isFetchingMore = true; else _isLoading = true;
      _error = null;
    });

    try {
      final response = await _movieService.searchKeywords(
        query: _currentQuery,
        page: _currentPage,
      );
      
      if (mounted) {
        setState(() {
          if (loadMore) {
            _keywordSearchResponse?.results.addAll(response.results);
            _keywordSearchResponse = KeywordSearchResponse(
              page: response.page,
              results: _keywordSearchResponse?.results ?? response.results,
              totalPages: response.totalPages,
              totalResults: response.totalResults,
            );
          } else {
            _keywordSearchResponse = response;
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
    _keywordSearchResponse != null &&
    _currentPage < _keywordSearchResponse!.totalPages) {
      _currentPage++;
      _fetchKeywords(loadMore: true);
    }
  }

  void _navigateToKeywordMovies(Keyword keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeywordMoviesPage(
          keyword: keyword,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search Keywords...',
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
                  _keywordSearchResponse = null;
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
    if (_isLoading && (_keywordSearchResponse == null || _keywordSearchResponse!.results.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    
    if (_keywordSearchResponse == null && _currentQuery.isEmpty) {
      return const Center(child: Text('Start typing to search keywords...'));
    }
    
    if (_keywordSearchResponse == null || _keywordSearchResponse!.results.isEmpty) {
      return Center(child: Text('No keywords found for "$_currentQuery".'));
    }

    final keywords = _keywordSearchResponse!.results;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: keywords.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == keywords.length && _isFetchingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0), 
              child: CircularProgressIndicator()
            )
          );
        }
        
        final keyword = keywords[index];
        return _buildKeywordCard(context, keyword);
      },
    );
  }

  Widget _buildKeywordCard(BuildContext context, Keyword keyword) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          keyword.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.movie_filter_outlined),
        onTap: () => _navigateToKeywordMovies(keyword),
      ),
    );
  }
}

class KeywordMoviesPage extends StatefulWidget {
  final Keyword keyword;

  const KeywordMoviesPage({Key? key, required this.keyword}) : super(key: key);

  @override
  State<KeywordMoviesPage> createState() => _KeywordMoviesPageState();
}

class _KeywordMoviesPageState extends State<KeywordMoviesPage> {
  final MovieService _movieService = MovieService();
  KeywordMoviesResponse? _keywordMoviesResponse;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _isFetchingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchKeywordMovies();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchKeywordMovies({bool loadMore = false}) async {
    setState(() {
      if (loadMore) _isFetchingMore = true; else _isLoading = true;
      _error = null;
    });

    try {
      final response = await _movieService.getMoviesByKeyword(
        keywordId: widget.keyword.id,
        page: _currentPage,
      );
      
      if (mounted) {
        setState(() {
          if (loadMore) {
            _keywordMoviesResponse?.results.addAll(response.results);
            _keywordMoviesResponse = KeywordMoviesResponse(
              id: response.id,
              page: response.page,
              results: _keywordMoviesResponse?.results ?? response.results,
              totalPages: response.totalPages,
              totalResults: response.totalResults,
            );
          } else {
            _keywordMoviesResponse = response;
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
    _keywordMoviesResponse != null &&
    _currentPage < _keywordMoviesResponse!.totalPages) {
      _currentPage++;
      _fetchKeywordMovies(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies with "${widget.keyword.name}" Keyword'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && (_keywordMoviesResponse == null || _keywordMoviesResponse!.results.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    
    if (_keywordMoviesResponse == null || _keywordMoviesResponse!.results.isEmpty) {
      return const Center(child: Text('No movies found for this keyword.'));
    }

    final movies = _keywordMoviesResponse!.results;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: movies.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == movies.length && _isFetchingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0), 
              child: CircularProgressIndicator()
            )
          );
        }
        
        final movie = movies[index];
        return _buildMovieCard(context, movie);
      },
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
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
              builder: (context) => MovieDetailPage(movie: movie),
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