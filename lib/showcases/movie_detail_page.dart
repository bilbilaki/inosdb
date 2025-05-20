import 'package:flutter/material.dart';
import 'package:miko/showcases/movies_by_keyword_screen.dart';
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
  List<Keyword> _movieKeywords = [];
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
            // Показываем базовую информацию о фильме во время загрузки деталей
            return _buildLoadingView();
          } else if (snapshot.hasError) {
            // Используем snapshot.error для сообщения об ошибке
            return _buildErrorView(context, snapshot.error.toString());
          } else if (snapshot.hasData) {
            final detailedMovie = snapshot.data!['details'] as Movie;
            final credits = snapshot.data!['credits'] as MovieCredits;
            recommendations = snapshot.data!['recommendations'] as MovieResponse;

            // --- ИЗВЛЕКАЕМ КЛЮЧЕВЫЕ СЛОВА ---
            // --- EXTRACT KEYWORDS ---
            // Предполагаем, что detailedMovie (объект Movie) теперь содержит поле keywords
            // Assumes detailedMovie (Movie object) now contains the keywords field
            _movieKeywords = detailedMovie.keywords;

            return _buildDetailView(context, detailedMovie, credits);
          } else {
            // Не должно произойти, если future завершается без данных и без ошибки
            return _buildErrorView(context, 'No data received.');
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Stack(
      children: [
        _buildDetailView(context, widget.movie, null, showDetailedInfo: false),
        Container(
          color: Colors.black54,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Stack(
      children: [
        _buildDetailView(context, widget.movie, null, showDetailedInfo: false),
        Container(
          color: Colors.black87,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading movie details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadMovieData(); // Повторная загрузка данных
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
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
    // ... (ваш существующий _buildAppBar без изменений)
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
    // В этом методе мы добавим вызов _buildKeywordsSection
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (все ваши существующие виджеты здесь: Tagline, Poster, Info, Overview, Cast, Crew, etc.)
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
                    if (showDetailedInfo && movie.genres!.isNotEmpty)
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

          // --- ДОБАВЬТЕ ВЫЗОВ СЕКЦИИ КЛЮЧЕВЫХ СЛОВ ЗДЕСЬ ---
          // --- ADD KEYWORDS SECTION CALL HERE ---
          if (showDetailedInfo && _movieKeywords.isNotEmpty)
             _buildKeywordsSection(context, _movieKeywords),
          
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
                  onPressed: () {},
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
              height: 180, // Adjusted for better text visibility
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: credits.cast.length,
                itemBuilder: (context, index) {
                  final castMember = credits.cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => _navigateToPersonDetail(castMember.id, castMember.name, castMember.profilePath),
                      child: SizedBox( // Added SizedBox for defined width
                        width: 100,
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
                                    height: 100, // Keep image square or defined aspect
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
                    ),
                  );
                },
              ),
            ),
          ],
          // ... (остальная часть вашего _buildMovieDetails: Crew, Production, Budget, Recommendations, etc.)
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
                        child: SizedBox( // Added SizedBox for defined width
                          width: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 4,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: director.profilePath != null ? NetworkImage(director.fullProfilePath) : null,
                                  onBackgroundImageError: director.profilePath != null ? (_, __) {} : null,
                                  child: director.profilePath == null
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
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
                height: 80, // Increased height a bit
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movie.productionCompanies!.length,
                  itemBuilder: (context, index) {
                    final company = movie.productionCompanies![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (company.logoPath != null)
                            SizedBox(
                              height: 40,
                              width: 80, // Give some width for logo or text
                              child: Image.network(
                                company.fullLogoPath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Text(
                                        company.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: Text(
                              company.name,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  if (movie.budget != null && movie.budget! > 0) ...[
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Budget',
                        movie.formattedBudget,
                        Icons.attach_money,
                      ),
                    ),
                    if (movie.revenue != null && movie.revenue! > 0)
                      const SizedBox(width: 16),
                  ],
                  if (movie.revenue != null && movie.revenue! > 0)
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
                        // TODO: Launch URL (would need url_launcher package)
                        // import 'package:url_launcher/url_launcher.dart';
                        // if (await canLaunchUrl(Uri.parse(movie.homepage!))) {
                        //   await launchUrl(Uri.parse(movie.homepage!));
                        // }
                      },
                    ),
                  if (movie.imdbId != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.movie),
                      label: const Text('IMDb'),
                      onPressed: () {
                        // TODO: Launch IMDb URL
                        // final imdbUrl = 'https://www.imdb.com/title/${movie.imdbId}/';
                        // if (await canLaunchUrl(Uri.parse(imdbUrl))) {
                        //   await launchUrl(Uri.parse(imdbUrl));
                        // }
                      },
                    ),
                ],
              ),
            ],
          ],

          const SizedBox(height: 32),
          _buildRecommendationsSection(context),
        ],
      ),
    );
  }

  // --- НОВЫЙ МЕТОД ДЛЯ ОТОБРАЖЕНИЯ КЛЮЧЕВЫХ СЛОВ ---
  // --- NEW METHOD TO BUILD THE KEYWORDS SECTION ---
  Widget _buildKeywordsSection(BuildContext context, List<Keyword> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Keywords',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, // Горизонтальный отступ
          runSpacing: 8.0, // Вертикальный отступ
          children: keywords.map((keyword) {
            return ActionChip(
              label: Text(keyword.name),
              backgroundColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white70),
              onPressed: () {
                // Переход на экран с фильмами по этому ключевому слову
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoviesByKeywordScreen(
                      keywordId: keyword.id,
                      keywordName: keyword.name,
                      movieService: _movieService, // Передаем экземпляр сервиса
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
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
    // ... (ваш существующий _buildRecommendationsSection без изменений)
    if (recommendations == null || recommendations!.results.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0), // Adjusted padding
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
          height: 230, // Adjusted height for better text visibility
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Adjusted padding
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
    // ... (ваш существующий _buildRecommendationCard без изменений)
    return GestureDetector(
      onTap: () {
        // Используем pushReplacement, если хотим заменить текущий детальный экран,
        // или push, если хотим добавить в стек. Для рекомендаций обычно push.
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
            Hero( // Added Hero to recommendation card poster
              tag: 'movie-recommendation-${movie.id}', // Unique tag
              child: ClipRRect(
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
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13, // Slightly larger
                fontWeight: FontWeight.bold,
              ),
            ),
            if (movie.releaseDate.isNotEmpty && movie.releaseDate.length >= 4)
              Text(
                movie.releaseDate.substring(0,4), // Just year
                style: TextStyle(
                  fontSize: 11, // Slightly larger
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Color _getRatingColor(double rating) {
    // ... (ваш существующий _getRatingColor без изменений)
    if (rating >= 7.5) {
      return Colors.green.shade700;
    } else if (rating >= 5.0) {
      return Colors.orange.shade700;
    } else if (rating > 0.0) {
      return Colors.red.shade700;
    }
    return Colors.grey.shade700; // For 0.0 rating
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    // ... (ваш существующий _buildInfoCard без изменений)
    return Card(
      color: Colors.grey[850],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Adjusted padding
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.secondary), // Adjusted size and color
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70), // Adjusted style
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Adjusted style
            ),
          ],
        ),
      ),
    );
  }
}