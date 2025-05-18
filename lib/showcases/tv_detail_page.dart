import 'package:flutter/material.dart';
import 'tv_model.dart';
import 'movie_service.dart';
import 'person_detail_page.dart';

class TvShowDetailPage extends StatefulWidget {
  final TvShow tvShow;

  const TvShowDetailPage({Key? key, required this.tvShow}) : super(key: key);

  @override
  State<TvShowDetailPage> createState() => _TvShowDetailPageState();
}

class _TvShowDetailPageState extends State<TvShowDetailPage> with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  late Future<Map<String, dynamic>> _tvShowDataFuture;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late TabController _tabController;
  TvShowResponse? recommendations;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTvShowDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _movieService.dispose();
    super.dispose();
  }
  
  void _loadTvShowDetails() {
    _tvShowDataFuture = _movieService.getTvShowDetailsWithRecommendations(tvShowId: widget.tvShow.id);
    _tvShowDataFuture.then((_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tvShowDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          } else if (snapshot.hasError || _hasError) {
            return _buildErrorView(context);
          } else if (snapshot.hasData) {
            final detailedTvShow = snapshot.data!['details'] as TvShow;
            recommendations = snapshot.data!['recommendations'] as TvShowResponse;
            return _buildDetailView(context, detailedTvShow);
          } else {
            // Fallback to use the basic TV show data if detailed data isn't available
            return _buildDetailView(context, widget.tvShow);
          }
        },
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return Stack(
      children: [
        // Show the basic TV show info in the background while loading
        _buildDetailView(context, widget.tvShow),
        
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
        // Show the basic TV show info in the background
        _buildDetailView(context, widget.tvShow),
        
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
                  'Error loading TV show details',
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
                    _loadTvShowDetails();
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

  Widget _buildDetailView(BuildContext context, TvShow tvShow) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildAppBar(context, tvShow),
          SliverToBoxAdapter(
            child: _buildTvShowHeader(context, tvShow),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'OVERVIEW'),
                  Tab(text: 'SEASONS'),
                  Tab(text: 'EPISODES'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, tvShow),
          _buildSeasonsTab(context, tvShow),
          _buildEpisodesTab(context, tvShow),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TvShow tvShow) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tvShow.name,
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
              tvShow.fullBackdropPath,
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
            if (tvShow.tagline != null && tvShow.tagline!.isNotEmpty)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Text(
                  '"${tvShow.tagline!}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
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

  Widget _buildTvShowHeader(BuildContext context, TvShow tvShow) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Hero(
            tag: 'tvshow-${tvShow.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 180,
                child: Image.network(
                  tvShow.fullPosterPath,
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
          // TV show info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tvShow.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (tvShow.originalName != tvShow.name)
                  Text(
                    '(${tvShow.originalName})',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${tvShow.voteAverage.toStringAsFixed(1)} (${tvShow.voteCount} votes)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tvShow.airDateRange,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tvShow.episodeRunTime != null && tvShow.episodeRunTime!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Episode: ${tvShow.formattedRuntime}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      tvShow.originCountryText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tvShow.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tvShow.status!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tvShow.formattedStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, TvShow tvShow) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview section
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            tvShow.overview.isEmpty ? 'No overview available.' : tvShow.overview,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          // Genres section
          Text(
            'Genres',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tvShow.genreNames.map((genreName) {
              return Chip(
                label: Text(genreName),
                backgroundColor: Colors.grey[800],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Creators section
          if (tvShow.createdBy != null && tvShow.createdBy!.isNotEmpty) ...[
            Text(
              'Created by',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tvShow.createdBy!.length,
                itemBuilder: (context, index) {
                  final creator = tvShow.createdBy![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () => _navigateToPersonDetail(creator.id, creator.name, creator.profilePath),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(creator.fullProfilePath),
                            onBackgroundImageError: (_, __) {},
                            child: creator.profilePath == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              creator.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
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
          
          const SizedBox(height: 24),
          
          // Network section
          if (tvShow.networks != null && tvShow.networks!.isNotEmpty) ...[
            Text(
              'Networks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tvShow.networks!.length,
                itemBuilder: (context, index) {
                  final network = tvShow.networks![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: network.logoPath != null
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(
                                    network.fullLogoPath,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    network.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          network.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          network.originCountry,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Production companies section
          if (tvShow.productionCompanies != null && tvShow.productionCompanies!.isNotEmpty) ...[
            Text(
              'Production Companies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: tvShow.productionCompanies!.map((company) {
                return Column(
                  children: [
                    Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: company.logoPath != null
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.network(
                                company.fullLogoPath,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Center(
                              child: Text(
                                company.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: Text(
                        company.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Show stats
          if (tvShow.numberOfSeasons != null || tvShow.numberOfEpisodes != null) ...[
            Text(
              'Show Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (tvShow.numberOfSeasons != null)
                  _buildStatCard(
                    context,
                    'Seasons',
                    tvShow.numberOfSeasons.toString(),
                    Icons.collections_bookmark,
                  ),
                if (tvShow.numberOfEpisodes != null)
                  _buildStatCard(
                    context,
                    'Episodes',
                    tvShow.numberOfEpisodes.toString(),
                    Icons.video_library,
                  ),
              ],
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Recommendations Section
          _buildRecommendationsSection(context),
        ],
      ),
    );
  }
  
  Widget _buildSeasonsTab(BuildContext context, TvShow tvShow) {
    if (tvShow.seasons == null || tvShow.seasons!.isEmpty) {
      return const Center(
        child: Text('No seasons information available'),
      );
    }
    
    // Sort seasons by season number
    final sortedSeasons = List<Season>.from(tvShow.seasons!)
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedSeasons.length,
      itemBuilder: (context, index) {
        final season = sortedSeasons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              // Navigate to season detail page (could be implemented later)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Season ${season.seasonNumber} selected'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season poster
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: Image.network(
                      season.fullPosterPath,
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
                // Season info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${season.episodeCount} episodes',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Air date: ${season.formattedAirDate}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (season.voteAverage > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                season.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (season.overview != null && season.overview!.isNotEmpty)
                          Text(
                            season.overview!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEpisodesTab(BuildContext context, TvShow tvShow) {
    if (tvShow.lastEpisodeToAir == null && tvShow.nextEpisodeToAir == null) {
      return const Center(
        child: Text('No episode information available'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next episode section
          if (tvShow.nextEpisodeToAir != null) ...[
            Text(
              'Next Episode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildEpisodeCard(context, tvShow.nextEpisodeToAir!, true),
            const SizedBox(height: 24),
          ],
          
          // Last episode section
          if (tvShow.lastEpisodeToAir != null) ...[
            Text(
              'Last Episode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildEpisodeCard(context, tvShow.lastEpisodeToAir!, false),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEpisodeCard(BuildContext context, Episode episode, bool isNext) {
    return Card(
      color: isNext ? Colors.blue.withOpacity(0.2) : Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNext ? Colors.blue : Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'S${episode.seasonNumber} | E${episode.episodeNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (episode.episodeType != 'standard')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEpisodeTypeColor(episode.episodeType),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      episode.formattedEpisodeType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              episode.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Air date: ${episode.formattedAirDate}',
              style: TextStyle(
                color: isNext ? Colors.blue[200] : Colors.grey[400],
                fontSize: 14,
              ),
            ),
            if (episode.runtime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Runtime: ${episode.formattedRuntime}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (episode.stillPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  episode.fullStillPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Text(
              episode.overview,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Returning Series':
        return Colors.green;
      case 'Ended':
        return Colors.orange;
      case 'Canceled':
        return Colors.red;
      case 'In Production':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  Color _getEpisodeTypeColor(String episodeType) {
    switch (episodeType) {
      case 'finale':
        return Colors.red;
      case 'mid_season':
        return Colors.orange;
      case 'premiere':
        return Colors.green;
      case 'special':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
                'Recommended Shows',
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
              final tvShow = recommendations!.results[index];
              return _buildRecommendationCard(context, tvShow);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildRecommendationCard(BuildContext context, TvShow tvShow) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TvShowDetailPage(tvShow: tvShow),
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
                    tvShow.fullPosterPath,
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
                        color: _getRatingColor(tvShow.voteAverage),
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
                            tvShow.voteAverage.toStringAsFixed(1),
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
              tvShow.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Year
            Text(
              tvShow.firstAirDate != null ? tvShow.year : 'TBA',
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}