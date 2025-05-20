import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'seasondetailpage.dart';
import 'tv_model.dart';
import 'movie_service.dart';
import 'person_detail_page.dart';
import 'episodedetailpage.dart';
import 'person_detail_page.dart';

class TvShowDetailPage extends StatefulWidget {
  final TvShow tvShow;

  const TvShowDetailPage({Key? key, required this.tvShow}) : super(key: key);

  @override
  State<TvShowDetailPage> createState() => _TvShowDetailPageState();
}

class _TvShowDetailPageState extends State<TvShowDetailPage>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  late Future<Map<String, dynamic>> _tvShowDataFuture;
  // Removed _isLoading, _hasError, _errorMessage as FutureBuilder handles this better for the main load

  late TabController _tabController;
  TvShowResponse? recommendations;
  TvShow? _detailedTvShow; // Store the fully loaded TvShow object

  // Futures for tab-specific data
  Future<TVCredits>? _creditsFuture;
  Future<YoutubeVideoForSeries>? _videosFuture;

  final List<Tab> _tabs = const [
    Tab(text: 'OVERVIEW'),
    Tab(text: 'SEASONS'),
    Tab(text: 'CAST'),
    Tab(text: 'VIDEOS'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadTvShowBaseDetails();
    // Initialize futures for tabs that require separate API calls
    // These will be triggered when the TvShow ID is available
  }

  @override
  void dispose() {
    _tabController.dispose();
    _movieService.dispose();
    super.dispose();
  }

  void _loadTvShowBaseDetails() {
    _tvShowDataFuture = _movieService.getTvShowDetailsWithRecommendations(
        tvShowId: widget.tvShow.id);
    // Once base details are loaded, we can trigger dependent futures
    _tvShowDataFuture.then((data) {
      if (mounted && data['details'] != null) {
        final loadedShow = data['details'] as TvShow;
        setState(() {
          _detailedTvShow = loadedShow; // Store for use in tabs
          // Initialize futures that need the tvShowId
          _creditsFuture =
              _movieService.getTVCredits(tvId: loadedShow.id);
          _videosFuture =
              _movieService.getTvShowVideos(tvShowId: loadedShow.id);
        });
      }
    }).catchError((e) {
      // Error is handled by FutureBuilder for _tvShowDataFuture
      print("Error loading base TV Show details: $e");
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tvShowDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _detailedTvShow == null) {
            // Show loading view only if _detailedTvShow is not yet set (initial load)
            return _buildLoadingView(
                widget.tvShow); // Use initial basic tvShow for loading view
          } else if (snapshot.hasError && _detailedTvShow == null) {
            return _buildErrorView(
                context, snapshot.error.toString(), widget.tvShow);
          } else if (snapshot.hasData || _detailedTvShow != null) {
            // Proceed if we have new data or already loaded _detailedTvShow
            if (snapshot.hasData) {
              _detailedTvShow = snapshot.data!['details']
                  as TvShow?; // Update with fresh data
              recommendations =
                  snapshot.data!['recommendations'] as TvShowResponse?;
            }
            if (_detailedTvShow == null) {
              // Should not happen if logic is correct
              return _buildErrorView(
                  context, "Failed to load show details.", widget.tvShow);
            }
            return _buildDetailView(context, _detailedTvShow!);
          } else {
            // Fallback, should ideally not be reached if logic is sound
            return _buildErrorView(
                context, "An unexpected error occurred.", widget.tvShow);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView(TvShow basicTvShow) {
    // Pass basic TvShow for the background
    return Stack(
      children: [
        _buildScaffoldContent(
            context, basicTvShow, true), // Show basic info blurred
        Container(
          color: Colors.black54,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorView(
      BuildContext context, String errorMessage, TvShow basicTvShow) {
    return Stack(
      children: [
        _buildScaffoldContent(
            context, basicTvShow, true), // Show basic info blurred
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
                  Text('Error loading TV show details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Reset detailed show and reload
                        _detailedTvShow = null;
                        recommendations = null;
                        _loadTvShowBaseDetails();
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

  // Helper to build the main scaffold structure, used by loading/error/success states
  Widget _buildScaffoldContent(
      BuildContext context, TvShow tvShow, bool isBackgroundOnly) {
    if (isBackgroundOnly) {
      // Simplified view for background during loading/error
      return CustomScrollView(
        slivers: [
          _buildAppBar(context, tvShow),
          SliverToBoxAdapter(child: _buildTvShowHeader(context, tvShow)),
        ],
      );
    }
    // Full view for when data is loaded
    return _buildDetailView(context, tvShow);
  }

  Widget _buildDetailView(BuildContext context, TvShow tvShow) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildAppBar(context, tvShow),
          SliverToBoxAdapter(child: _buildTvShowHeader(context, tvShow)),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: _tabs,
                isScrollable: true, // If many tabs
                indicatorColor: Theme.of(context).colorScheme.secondary,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor: Colors.grey,
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
          _buildCastTab(context, tvShow.id), // Pass ID for fetching
          _buildVideosTab(context, tvShow.id), // Pass ID for fetching
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TvShow tvShow) {
    // Your existing _buildAppBar code (no changes needed here)
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
                  offset: Offset(2.0, 2.0)),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              tvShow.fullBackdropPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 50))),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            if (tvShow.tagline != null && tvShow.tagline!.isNotEmpty)
              Positioned(
                bottom: 60, // Adjust if needed based on tab bar height
                left: 16,
                right: 16,
                child: Text(
                  '"${tvShow.tagline!}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0)),
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
    // Your existing _buildTvShowHeader code (no changes needed here)
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 30))),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tvShow.name,
                    style: Theme.of(context).textTheme.titleLarge),
                if (tvShow.originalName != tvShow.name)
                  Text('(${tvShow.originalName})',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                      '${tvShow.voteAverage.toStringAsFixed(1)} (${tvShow.voteCount} votes)',
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(tvShow.airDateRange,
                          style: Theme.of(context).textTheme.bodyMedium)),
                ]),
                const SizedBox(height: 8),
                if (tvShow.episodeRunTime != null &&
                    tvShow.episodeRunTime!.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 4),
                    Text('Avg. Episode: ${tvShow.formattedRuntime}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                const SizedBox(height: 8),
                if (tvShow.originCountry.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.flag_outlined, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(tvShow.originCountryText,
                            style: Theme.of(context).textTheme.bodyMedium)),
                  ]),
                const SizedBox(height: 8),
                if (tvShow.status != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tvShow.status!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(tvShow.formattedStatus,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, TvShow tvShow) {
    // Combines old Overview and parts of old Episodes tab
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
              tvShow.overview.isEmpty
                  ? 'No overview available.'
                  : tvShow.overview,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          if (tvShow.genres != null && tvShow.genres!.isNotEmpty) ...[
            Text('Genres', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tvShow.genres!
                    .map((genre) => Chip(
                        label: Text(genre.name),
                        backgroundColor: Colors.grey[800]))
                    .toList()),
            const SizedBox(height: 24),
          ],

          if (tvShow.createdBy != null && tvShow.createdBy!.isNotEmpty) ...[
            Text('Created by', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 150, // Adjusted height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tvShow.createdBy!.length,
                itemBuilder: (context, index) {
                  final creator = tvShow.createdBy![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () => _navigateToPersonDetail(
                          creator.id, creator.name, creator.profilePath),
                      child: SizedBox(
                        width: 90,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: creator.profilePath != null
                                  ? NetworkImage(creator.fullProfilePath)
                                  : null,
                              onBackgroundImageError:
                                  creator.profilePath != null
                                      ? (_, __) {}
                                      : null,
                              child: creator.profilePath == null
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(creator.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Last and Next Episode
          if (tvShow.nextEpisodeToAir != null) ...[
            Text('Next Episode to Air',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildEpisodeCard(
                context, tvShow.id, tvShow.nextEpisodeToAir!, true),
            const SizedBox(height: 24),
          ],
          if (tvShow.lastEpisodeToAir != null) ...[
            Text('Last Episode Aired',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildEpisodeCard(
                context, tvShow.id, tvShow.lastEpisodeToAir!, false),
            const SizedBox(height: 24),
          ],

          if (tvShow.networks != null && tvShow.networks!.isNotEmpty) ...[
            Text('Networks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(/* ... Your network display code ... */),
            const SizedBox(height: 24),
          ],

          if (tvShow.numberOfSeasons != null ||
              tvShow.numberOfEpisodes != null) ...[
            Text('Show Statistics',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Better spacing
              children: [
                if (tvShow.numberOfSeasons != null)
                  Expanded(
                      child: _buildStatCard(
                          context,
                          'Seasons',
                          tvShow.numberOfSeasons.toString(),
                          Icons.movie_filter_outlined)),
                if (tvShow.numberOfSeasons != null &&
                    tvShow.numberOfEpisodes != null)
                  const SizedBox(width: 16),
                if (tvShow.numberOfEpisodes != null)
                  Expanded(
                      child: _buildStatCard(
                          context,
                          'Episodes',
                          tvShow.numberOfEpisodes.toString(),
                          Icons.list_alt_outlined)),
              ],
            ),
            const SizedBox(height: 24),
          ],

          _buildRecommendationsSection(context),
        ],
      ),
    );
  }

  Widget _buildSeasonsTab(BuildContext context, TvShow tvShow) {
    if (tvShow.seasons == null || tvShow.seasons!.isEmpty) {
      return const Center(child: Text('No seasons information available.'));
    }

    final sortedSeasons = List<Season>.from(tvShow.seasons!)
      ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedSeasons.length,
      itemBuilder: (context, index) {
        final season = sortedSeasons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeasonDetailPage(
                    tvShowId: tvShow.id,
                    seasonNumber: season.seasonNumber,
                    seasonName: season.name,
                    posterPath: season.posterPath, // Pass poster for app bar
                    movieService: _movieService,
                  ),
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
                    season.fullPosterPath,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.broken_image))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(season.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                            '${season.episodeCount} episodes • Air Date: ${season.formattedAirDate}',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14)),
                        if (season.voteAverage > 0) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(season.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14)),
                          ]),
                        ],
                        const SizedBox(height: 8),
                        if (season.overview != null &&
                            season.overview!.isNotEmpty)
                          Text(season.overview!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14)),
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

  Widget _buildCastTab(BuildContext context, int tvShowId) {
    if (_creditsFuture == null) {
      // Ensure future is initialized
      _creditsFuture = _movieService.getTVCredits(tvId: tvShowId);
    }
    return FutureBuilder<TVCredits>(
      future: _creditsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading cast: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.cast.isNotEmpty) {
          final cast = snapshot.data!.cast
            ..sort((a, b) => a.order.compareTo(b.order)); // Sort by order
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return GestureDetector(
                onTap: () => _navigateToPersonDetail(
                    member.id, member.name, member.profilePath),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          member.profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[800],
                              child: const Center(child: Icon(Icons.person))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(member.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    if (member.character != null)
                      Text(member.character!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[400])),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No cast information available.'));
        }
      },
    );
  }
    
  // Widget _buildCastList() {
  //   return ListView.builder(
  //     itemCount: _tvCredits?.cast.length ?? 0,
  //     itemBuilder: (context, index) {
  //       final cast = _tvCredits!.cast[index];
  //       return ListTile(
  //         leading: cast.profileImageUrl.isNotEmpty
  //             ? CircleAvatar(
  //                 backgroundImage: NetworkImage(cast.profileImageUrl),
  //               )
  //             : CircleAvatar(child: Icon(Icons.person)),
  //         title: Text(cast.name),
  //         subtitle: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Character: ${cast.character}'),
  //             Text('Gender: ${cast.genderString}'),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildCrewList() {
  //   return ListView.builder(
  //     itemCount: _tvCredits?.crew.length ?? 0,
  //     itemBuilder: (context, index) {
  //       final crew = _tvCredits!.crew[index];
  //       return ListTile(
  //         leading: crew.profileImageUrl.isNotEmpty
  //             ? CircleAvatar(
  //                 backgroundImage: NetworkImage(crew.profileImageUrl),
  //               )
  //             : CircleAvatar(child: Icon(Icons.person)),
  //         title: Text(crew.name),
  //         subtitle: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Department: ${crew.department}'),
  //             Text('Job: ${crew.job}'),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
    
  Widget _buildVideosTab(BuildContext context, int tvShowId) {
    if (_videosFuture == null) {
      // Ensure future is initialized
      _videosFuture = _movieService.getTvShowVideos(tvShowId: tvShowId);
    }
    return FutureBuilder<YoutubeVideoForSeries>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading videos: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.results.isNotEmpty) {
          final videos = snapshot.data!.results
              .where((v) => v.site.toLowerCase() == 'youtube')
              .toList();
          if (videos.isEmpty)
            return const Center(child: Text('No YouTube videos available.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final thumbnailUrl =
                  'https://img.youtube.com/vi/${video.key}/hqdefault.jpg';
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _launchUrl(video.youtubeUrl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            errorBuilder: (c, e, s) => Container(
                                height: 180,
                                color: Colors.grey[800],
                                child: const Center(
                                    child: Icon(Icons.play_circle_fill,
                                        size: 50))),
                          ),
                          Icon(Icons.play_circle_fill,
                              color: Colors.white.withOpacity(0.8), size: 60),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(video.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 12.0),
                        child: Text(video.type,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[400])),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No videos available.'));
        }
      },
    );
  }

  // Modified _buildEpisodeCard to accept tvShowId for navigation
  Widget _buildEpisodeCard(
      BuildContext context, int tvShowId, Episode episode, bool isNext) {
    return Card(
      color: isNext
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
          : Colors.grey[850],
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EpisodeDetailPage(
                tvShowId: tvShowId, // Use the passed tvShowId
                seasonNumber: episode.seasonNumber,
                episodeNumber: episode.episodeNumber,
                episodeName: episode.name, // Pass name for AppBar
                movieService: _movieService,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: isNext
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                      'S${episode.seasonNumber} | E${episode.episodeNumber}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                if (episode.episodeType != 'standard')
                  Container(/* ... your episode type chip ... */)
              ]),
              const SizedBox(height: 12),
              Text(episode.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Air date: ${episode.formattedAirDate}',
                  style: TextStyle(
                      color: isNext
                          ? Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.8)
                          : Colors.grey[400],
                      fontSize: 14)),
              if (episode.runtime != null) ...[
                const SizedBox(height: 4),
                Text('Runtime: ${episode.formattedRuntime}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
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
                      errorBuilder: (c, e, s) => Container(
                          height: 150,
                          color: Colors.grey[800],
                          child: const Center(child: Icon(Icons.broken_image))),
                    )),
              const SizedBox(height: 12),
              Text(episode.overview,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    // Your existing _buildStatCard code
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon,
                size: 30, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall), // titleSmall for less emphasis
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    /* Your existing code */
    switch (status) {
      case 'Returning Series':
        return Colors.green;
      case 'Ended':
        return Colors.orange;
      case 'Canceled':
        return Colors.red;
      case 'In Production':
        return Colors.blue;
      case 'Pilot':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getEpisodeTypeColor(String episodeType) {
    /* Your existing code */
    switch (episodeType) {
      case 'finale':
        return Colors.red.shade700;
      case 'mid_season':
        return Colors.orange.shade700;
      case 'premiere':
        return Colors.green.shade700;
      default:
        return Colors.blueGrey.shade700; // Standard or other
    }
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    /* Your existing code */
    if (recommendations == null || recommendations!.results.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text('Recommended Shows',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 230, // Adjusted for better title visibility
          child: ListView.builder(
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
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, TvShow tvShow) {
    /* Your existing code */
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          // Use pushReplacement if you want to replace the current detail page
          context,
          MaterialPageRoute(
              builder: (context) => TvShowDetailPage(tvShow: tvShow)),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'tv-recommendation-${tvShow.id}', // Unique tag
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      tvShow.fullPosterPath,
                      height: 170,
                      width: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          height: 170,
                          width: 130,
                          color: Colors.grey[800],
                          child: const Center(child: Icon(Icons.tv))),
                    ),
                    if (tvShow.voteAverage > 0)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRatingColor(tvShow.voteAverage),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 2),
                            Text(tvShow.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(tvShow.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            if (tvShow.firstAirDate != null && tvShow.firstAirDate!.isNotEmpty)
              Text(tvShow.year,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    /* Your existing code */
    if (rating >= 7.5) return Colors.green.shade700;
    if (rating >= 5.0) return Colors.orange.shade700;
    if (rating > 0) return Colors.red.shade700;
    return Colors.blueGrey.shade700;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  // Your existing _SliverAppBarDelegate code
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _tabBar); // Use theme color
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
