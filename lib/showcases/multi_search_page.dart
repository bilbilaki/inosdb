// multi_search_page.dart
import 'package:flutter/material.dart';
import 'package:miko/showcases/tv_model.dart';
import 'dart:async';
import 'movie_service.dart';
import 'movie_model.dart';
import 'person_detail_page.dart';
import 'movie_detail_page.dart';
import 'tv_detail_page.dart';

class MultiSearchPage extends StatefulWidget {
  const MultiSearchPage({Key? key}) : super(key: key);

  @override
  State<MultiSearchPage> createState() => _MultiSearchPageState();
}

class _MultiSearchPageState extends State<MultiSearchPage> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  MultiSearchResponse? _searchResponse;
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
        _searchResponse = null;
        if (_currentQuery.isNotEmpty) {
          _fetchMultiSearch();
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

  Future<void> _fetchMultiSearch({bool loadMore = false}) async {
    if (_currentQuery.isEmpty || _isFetchingMore) return;

    setState(() {
      if (loadMore) {
        _isFetchingMore = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });

    try {
      final response = await _movieService.multiSearch(
        query: _currentQuery,
        page: _currentPage,
      );
      
      if (mounted) {
        setState(() {
          if (loadMore) {
            _searchResponse?.results.addAll(response.results);
            _searchResponse = MultiSearchResponse(
              page: response.page,
              results: _searchResponse?.results ?? response.results,
              totalPages: response.totalPages,
              totalResults: response.totalResults,
            );
          } else {
            _searchResponse = response;
          }
          
          if (loadMore) {
            _isFetchingMore = false;
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          if (loadMore) {
            _isFetchingMore = false;
          } else {
            _isLoading = false;
          }
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
      _fetchMultiSearch(loadMore: true);
    }
  }

  void _navigateToDetailPage(MultiSearchResult result) {
    switch (result.mediaType) {
      case MediaType.movie:
        if (result is MultiSearchMovie) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(
                movie: Movie(
                  id: result.id,
                  title: result.name,
                  originalTitle: result.originalName,
                  posterPath: result.posterPath,
                  backdropPath: result.backdropPath, adult: result.adult, genreIds: result.genreIds, originalLanguage: result.originalLanguage.toString(), overview: result.overview.toString(), popularity: result.popularity, voteAverage: result.voteAverage, voteCount: result.voteCount, releaseDate: result.releaseDate.toString(), video: result.video,
                  // Add other necessary fields from the multi search result
                ),
              ),
            ),
          );
        }
        break;
      case MediaType.tv:
        if (result is MultiSearchTV) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TvShowDetailPage(
                tvShow: TvShow(
                  id: result.id,
                  name: result.name,
                  originalName: result.originalName,
                  posterPath: result.posterPath,
                  backdropPath: result.backdropPath, adult: result.adult, genreIds: result.genreIds, originCountry: result.originCountry, originalLanguage: result.originalLanguage.toString(), overview: result.overview.toString(), popularity: result.popularity, voteAverage: result.voteAverage, voteCount: result.voteCount,
                  // Add other necessary fields from the multi search result
                ),
              ),
            ),
          );
        }
        break;
      case MediaType.person:
        if (result is MultiSearchPerson) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonDetailPage(
                personId: result.id,
                initialName: result.name,
                initialProfilePath: result.profilePath
              ),
            ),
          );
        }
        break;
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
            hintText: 'Multi Search (Movies, TV, People)...',
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
      return const Center(child: Text('Start typing to search...'));
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
        
        final result = results[index];
        return _buildMultiSearchResultCard(context, result);
      },
    );
  }

  Widget _buildMultiSearchResultCard(BuildContext context, MultiSearchResult result) {
    String? imagePath;
    String title = '';
    String subtitle = '';

    switch (result.mediaType) {
      case MediaType.movie:
        final movie = result as MultiSearchMovie;
        imagePath = movie.posterPath;
        title = movie.title;
        subtitle = 'Movie • ${movie.releaseDate ?? 'Unknown'}';
        break;
      case MediaType.tv:
        final tv = result as MultiSearchTV;
        imagePath = tv.posterPath;
        title = tv.name;
        subtitle = 'TV Show • ${tv.firstAirDate ?? 'Unknown'}';
        break;
      case MediaType.person:
        final person = result as MultiSearchPerson;
        imagePath = person.profilePath;
        title = person.name;
        subtitle = 'Person • ${person.knownForDepartment ?? 'Unknown'}';
        break;
    }

    final String posterUrl = imagePath != null
        ? 'https://inosdb.worker-inosuke.workers.dev/w500$imagePath'
        : 'https://via.placeholder.com/200x300?text=No+Image';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetailPage(result),
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
                  child: Center(
                    child: Icon(
                      result.mediaType == MediaType.movie 
                        ? Icons.movie_outlined 
                        : result.mediaType == MediaType.tv 
                          ? Icons.tv_outlined 
                          : Icons.person_outline
                    )
                  )
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
                      title, 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    Text(
                      subtitle, 
                      style: Theme.of(context).textTheme.bodySmall
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.mediaType == MediaType.movie 
                        ? (result as MultiSearchMovie).overview ?? ''
                        : result.mediaType == MediaType.tv 
                          ? (result as MultiSearchTV).overview ?? ''
                          : '',
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