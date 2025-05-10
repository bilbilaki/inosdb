import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';
import 'person_detail_page.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieService _movieService = MovieService();
  late Future<Map<String, dynamic>> _movieDataFuture;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  MovieResponse? recommendations;
  
  @override
  void initState() {
    super.initState();
    _loadMovieData();
  }
  
  @override
  void dispose() {
    _movieService.dispose();
    super.dispose();
  }
  
  void _loadMovieData() {
    _movieDataFuture = _movieService.getMovieDetailsWithCredits(movieId: widget.movie.id);
    _movieDataFuture.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          } else if (snapshot.hasError || _hasError) {
            return _buildErrorView(context);
          } else if (snapshot.hasData) {
            final detailedMovie = snapshot.data!['details'] as Movie;
            final credits = snapshot.data!['credits'] as MovieCredits;
            recommendations = snapshot.data!['recommendations'] as MovieResponse;
            return _buildDetailView(context, detailedMovie, credits);
          } else {
            // Fallback to use the basic movie data if detailed data isn't available
            return _buildDetailView(context, widget.movie, null);
          }
        },
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return Stack(
      children: [
        // Show the basic movie info in the background while loading
        _buildDetailView(context, widget.movie, null, showDetailedInfo: false),
        
        // Overlay with loading indicator
        Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorView(BuildContext context) {
    return Stack(
      children: [
        // Show the basic movie info in the background
        _buildDetailView(context, widget.movie, null, showDetailedInfo: false),
        
        // Error overlay
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading movie details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _loadMovieData();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(BuildContext context, Movie movie, MovieCredits? credits, {bool showDetailedInfo = true}) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, movie),
        SliverToBoxAdapter(
          child: _buildMovieDetails(context, movie, credits, showDetailedInfo),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Movie movie) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.fullBackdropPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieDetails(BuildContext context, Movie movie, MovieCredits? credits, bool showDetailedInfo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tagline if available
          if (showDetailedInfo && movie.tagline != null && movie.tagline!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '"${movie.tagline}"',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[400],
                ),
              ),
            ),
            
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Hero(
                tag: 'movie-${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    height: 180,
                    child: Image.network(
                      movie.fullPosterPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 30),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Movie info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Release Date: ${movie.releaseDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.voteAverage.toStringAsFixed(1)} (${movie.voteCount} votes)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (showDetailedInfo && movie.runtime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              movie.formattedRuntime,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (showDetailedInfo && movie.genres != null)
                      Text(
                        'Genres: ${movie.genresText}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Text(
                        'Original Language: ${movie.originalLanguage.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Directors section (if credits available)
          if (showDetailedInfo && credits != null && credits.directors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Director${credits.directors.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              credits.directors.map((director) => director.name).join(', '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          
          const SizedBox(height: 24),
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview.isEmpty ? 'No overview available.' : movie.overview,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          // Cast section
          if (showDetailedInfo && credits != null && credits.cast.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full cast page (could be implemented later)
                    // For now, just scroll to this section
                  },
                  child: Text(
                    'See all ${credits.cast.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: credits.cast.length,
                itemBuilder: (context, index) {
                  final castMember = credits.cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => _navigateToPersonDetail(castMember.id, castMember.name, castMember.profilePath),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'person-${castMember.id}',
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    castMember.fullProfilePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.person, size: 40),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  castMember.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  castMember.character,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Crew section (directors, writers, producers)
          if (showDetailedInfo && credits != null) ...[
            // Directors section
            if (credits.directors.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Directors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: credits.directors.length,
                  itemBuilder: (context, index) {
                    final director = credits.directors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => _navigateToPersonDetail(director.id, director.name, director.profilePath),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Material(
                              elevation: 4,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(director.fullProfilePath),
                                onBackgroundImageError: (_, __) {},
                                child: director.profilePath == null
                                    ? const Icon(Icons.person, size: 40)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 90,
                              child: Column(
                                children: [
                                  Text(
                                    director.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Director',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Writers section
            if (credits.writers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Writing',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: credits.writers.map((writer) {
                  return GestureDetector(
                    onTap: () => _navigateToPersonDetail(writer.id, writer.name, writer.profilePath),
                    child: Chip(
                      avatar: writer.profilePath != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(writer.fullProfilePath),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person, size: 16),
                            ),
                      label: Text('${writer.name} (${writer.job})'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Producers section
            if (credits.producers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Production',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: credits.producers.take(5).map((producer) {
                  return GestureDetector(
                    onTap: () => _navigateToPersonDetail(producer.id, producer.name, producer.profilePath),
                    child: Chip(
                      avatar: producer.profilePath != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(producer.fullProfilePath),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person, size: 16),
                            ),
                      label: Text('${producer.name} (${producer.job})'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                }).toList(),
              ),
              
              if (credits.producers.length > 5)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Show all producers (could be implemented later)
                    },
                    child: Text(
                      'See all ${credits.producers.length} producers',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ],
          
          if (showDetailedInfo) ...[
            // Production Information
            if (movie.productionCompanies != null && movie.productionCompanies!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Production Companies',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movie.productionCompanies!.length,
                  itemBuilder: (context, index) {
                    final company = movie.productionCompanies![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          if (company.logoPath != null)
                            Image.network(
                              company.fullLogoPath,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 40,
                                  width: 80,
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Text(
                                      company.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              height: 40,
                              width: 80,
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  company.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            company.name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Production Countries
            if (movie.productionCountries != null && movie.productionCountries!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Production Countries',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: movie.productionCountries!.map((country) {
                  return Chip(
                    label: Text(country.name),
                    backgroundColor: Colors.grey[800],
                  );
                }).toList(),
              ),
            ],
            
            // Budget and Revenue
            if (movie.budget != null || movie.revenue != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (movie.budget != null) ...[
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Budget',
                        movie.formattedBudget,
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (movie.revenue != null)
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Revenue',
                        movie.formattedRevenue,
                        Icons.trending_up,
                      ),
                    ),
                ],
              ),
            ],
            
            // Spoken Languages
            if (movie.spokenLanguages != null && movie.spokenLanguages!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Spoken Languages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: movie.spokenLanguages!.map((language) {
                  return Chip(
                    label: Text(language.englishName),
                    backgroundColor: Colors.grey[800],
                  );
                }).toList(),
              ),
            ],
            
            // External Links
            if (movie.homepage != null && movie.homepage!.isNotEmpty || movie.imdbId != null) ...[
              const SizedBox(height: 24),
              Text(
                'External Links',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  if (movie.homepage != null && movie.homepage!.isNotEmpty)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.language),
                      label: const Text('Official Website'),
                      onPressed: () {
                        // Launch URL (would need url_launcher package)
                      },
                    ),
                  if (movie.imdbId != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.movie),
                      label: const Text('IMDb'),
                      onPressed: () {
                        // Launch IMDb URL
                      },
                    ),
                ],
              ),
            ],
          ],
          
          const SizedBox(height: 32),
          
          // Recommendations Section
          _buildRecommendationsSection(context),
        ],
      ),
    );
  }
  
  void _navigateToPersonDetail(int personId, String name, String? profilePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailPage(
          personId: personId,
          initialName: name,
          initialProfilePath: profilePath,
        ),
      ),
    );
  }
  
  Widget _buildRecommendationsSection(BuildContext context) {
    if (recommendations == null || recommendations!.results.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (recommendations!.results.length > 10)
                TextButton(
                  onPressed: () {
                    // Could navigate to a full recommendations page in the future
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('More recommendations coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: recommendations!.results.length > 10 
                ? 10 
                : recommendations!.results.length,
            itemBuilder: (context, index) {
              final movie = recommendations!.results[index];
              return _buildRecommendationCard(context, movie);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildRecommendationCard(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    movie.fullPosterPath,
                    height: 170,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 170,
                        width: 130,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      );
                    },
                  ),
                  // Rating badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRatingColor(movie.voteAverage),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Year
            Text(
              movie.releaseDate,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRatingColor(double rating) {
    if (rating >= 8.0) {
      return Colors.green;
    } else if (rating >= 6.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}