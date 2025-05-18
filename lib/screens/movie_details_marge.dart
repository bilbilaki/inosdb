// lib/screens/movie_detail_page_merged.dart
// (Combining features from your original MovieDetailPage and MovieDetailsScreen)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

// Assuming these are your paths and models/services
import 'package:miko/models/movie.dart'
    as MikoMovieModel; // Aliasing to avoid name clash
import 'package:miko/services/user_data_service.dart';
import 'package:miko/providers/movie_provider.dart'; // If needed for initial movie
import 'package:miko/screens/video_player_screen.dart';
import 'package:miko/utils/colors.dart'; // Your AppColors

// From your original 'MovieDetailPage' structure (File 1)
import '../models/movie.dart'; // This is TMDB's Movie, MovieCredits etc. (File 2)
import '../models/movie.dart' as MikoMovie;
import '../providers/movie_provider.dart'; // Your TMDB MovieService (File 3)
import '../showcases/movie_model.dart' as TmdbApi;
import '../showcases/movie_service.dart';
import '../showcases/movie_service.dart' as TmdbApi;
import '../showcases/person_detail_page.dart'; // From File 1
//import '../showcases/movie_model.dart';

class MergedMovieDetailPage extends StatefulWidget {
  final MikoMovieModel.Movie movie; // This is YOUR Movie model from miko/models/movie.dart

  const MergedMovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MergedMovieDetailPage> createState() => _MergedMovieDetailPageState();
}

class _MergedMovieDetailPageState extends State<MergedMovieDetailPage> {
  final TmdbApi.MovieService _tmdbMovieService = TmdbApi.MovieService();
  late Future<Map<String, dynamic>> _movieDataFuture;

  bool _isFavorite = false;
  bool _isInWatchlist = false;
  UserDataService? _userDataService;

  @override
  void initState() {
    super.initState();
    _loadTmdbMovieData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userDataService == null) {
      _userDataService = Provider.of<UserDataService>(context, listen: false);
      _updateFavoriteStatus();
      _updateWatchlistStatus();
      // If UserDataService is a ChangeNotifier and you want to listen for external updates:
      // Provider.of<UserDataService>(context); // This establishes the listen
      // _userDataService?.addListener(_onUserDataChanged); // Or manual listener
    }
  }
  
  // void _onUserDataChanged() { // If using manual listener
  //   if (!mounted) return;
  //   _updateFavoriteStatus();
  //   _updateWatchlistStatus();
  // }

  void _updateFavoriteStatus() {
    if (_userDataService != null && mounted) {
      setState(() {
        _isFavorite = _userDataService!.isFavoriteMovie(widget.movie.id);
      });
    }
  }

  void _updateWatchlistStatus() {
    if (_userDataService != null && mounted) {
      setState(() {
        _isInWatchlist = _userDataService!.isOnWatchlistMovie(widget.movie.id);
      });
    }
  }

  @override
  void dispose() {
    _tmdbMovieService.dispose();
    // _userDataService?.removeListener(_onUserDataChanged); // If using manual listener
    super.dispose();
  }

  void _loadTmdbMovieData() {
    // Fetch TMDB details using the ID from your MikoMovie.Movie object
    _movieDataFuture = _tmdbMovieService.getMovieDetailsWithCredits(movieId: widget.movie.id);
  }

  // --- Miko's Helper Methods for Play/Download (Referenced from previous response, keep as is) ---
  void _showVideoSelectionDialog(BuildContext context, MikoMovieModel.Movie mikoMovie) {
    final List<MikoMovieModel.VideoInfo> videos = mikoMovie.parseVideoData();
    if (videos.isEmpty) {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('No trailers or clips found for this movie.'),
 duration: Duration(seconds: 2)),
 );
 return;
    }
    // Implement your dialog with these videos - example:
    showDialog(context: context, builder: (ctx) => SimpleDialog(
      title: const Text("Select Video"),
      children: videos.map((v) => SimpleDialogOption(
        onPressed: () {
          Navigator.pop(ctx);
          MikoMovie.launchVideo(v.key); // Assuming launchVideo is in your MikoMovie file
        },
        child: Text("${v.type}: ${v.title}"),
      )).toList(),
    ));
  }


  void _showDownloadLinkSelection(BuildContext context, List<String> links, String movieTitle) {
    if (links.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No streaming links available for this movie.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text('Play: $movieTitle'),
          titleTextStyle: const TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
          backgroundColor: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: links.map((link) {
            String qualityGuess = "Link";
            if (link.contains('1080p')) qualityGuess = "1080p";
            else if (link.contains('720p')) qualityGuess = "720p";
            else if (link.contains('480p')) qualityGuess = "480p";
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: link)));
              },
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Text('$qualityGuess - ${Uri.parse(link).host}', style: const TextStyle(color: AppColors.primaryText, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        );
      },
    );
  }

  void _realDownloadinglink(BuildContext context, List<String> links, String movieTitle) {
    if (links.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No download links available for this movie.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text('Download: $movieTitle'),
          titleTextStyle: const TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
          backgroundColor: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: links.map((link) {
            String qualityGuess = "Link";
            if (link.contains('1080p')) qualityGuess = "1080p";
            else if (link.contains('720p')) qualityGuess = "720p";
            else if (link.contains('480p')) qualityGuess = "480p";
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Download started for: $link (Not implemented)')),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Text('$qualityGuess - ${Uri.parse(link).host}', style: const TextStyle(color: AppColors.primaryText, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final mikoMovieInitial = widget.movie; // Your CSV loaded movie

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return _buildLoadingViewWithMikoFallback(mikoMovieInitial);
          } else if (snapshot.hasError) {
            return _buildErrorView(context, snapshot.error.toString(), mikoMovieInitial);
          } else if (snapshot.hasData) {
            final tmdbDetailedMovie = snapshot.data!['details'] as MikoMovie.Movie;
            final credits = snapshot.data!['credits'] as TmdbApi.MovieCredits;
            final recommendations = snapshot.data!['recommendations'] as TmdbApi.MovieResponse;
            
            return _buildDetailView(context, mikoMovieInitial, tmdbDetailedMovie as TmdbApi.Movie?, credits, recommendations);
          } else {
            return _buildDetailView(context, mikoMovieInitial, null, null, null);
          }
        },
      ),
    );
  }

  Widget _buildLoadingViewWithMikoFallback(MikoMovie.Movie mikoMovie) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildAppBar(context, mikoMovie, null),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMikoBasicInfoSection(context, mikoMovie, showTmdbRating: false),
              ),
            ),
          ],
        ),
        Container(
          color: Colors.black54,
          child: const Center(child: CircularProgressIndicator(color: AppColors.accentColor)),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage, MikoMovie.Movie mikoMovie) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildAppBar(context, mikoMovie, null),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMikoBasicInfoSection(context, mikoMovie, showTmdbRating: false),
              ),
            ),
          ],
        ),
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading movie details', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 8),
                Text(errorMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor),
                  onPressed: () { setState(() { _loadTmdbMovieData(); }); },
                  child: const Text('Try Again', style: TextStyle(color: AppColors.primaryText)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    MikoMovie.Movie mikoMovie,
    TmdbApi.Movie? tmdbDetailedMovie,
    TmdbApi.MovieCredits? credits,
    TmdbApi.MovieResponse? recommendations) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, mikoMovie, tmdbDetailedMovie),
        SliverToBoxAdapter(
          child: _buildMovieDetailsBody(context, mikoMovie, tmdbDetailedMovie, credits, recommendations),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, MikoMovie.Movie mikoMovie, TmdbApi.Movie? tmdbMovie) {
    final String appBarTitle = mikoMovie.title;
    final String? backdropUrl = mikoMovie.getBackdropUrl() ?? tmdbMovie?.fullBackdropPath;
    final String? posterUrlForFallback = mikoMovie.getPosterUrl() ?? tmdbMovie?.fullPosterPath;
    final double voteAverage = tmdbMovie?.voteAverage ?? mikoMovie.voteAverage;

    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: const Color.fromARGB(255, 71, 43, 91),
      iconTheme: const IconThemeData(color: AppColors.primaryText),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(appBarTitle, style: const TextStyle(color: AppColors.primaryText, fontSize: 16.0, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]), maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backdropUrl != null)
              CachedNetworkImage(
                imageUrl: backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.secondaryBackground),
                errorWidget: (context, url, error) => Container(
                  color: const Color.fromARGB(255, 33, 33, 33),
                  child: posterUrlForFallback != null
                      ? CachedNetworkImage(imageUrl: posterUrlForFallback, fit: BoxFit.contain)
                      : const Icon(Icons.movie_outlined, size: 100, color: AppColors.secondaryText),
                ),
              )
            else
              Container(color: AppColors.secondaryBackground, child: Center(child: Text(appBarTitle, style: const TextStyle(color: AppColors.primaryText, fontSize: 24)))),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.2), AppColors.primaryBackground.withOpacity(0.9), AppColors.primaryBackground],
                  stops: const [0.0, 0.5, 0.9, 1.0]),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.0,
              right: 8.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white, size: 20),
                    onPressed: () async {
                      if (_userDataService == null) return;
                      await _userDataService!.toggleFavoriteMovie(mikoMovie.id); // Assuming this method exists and works
                      _updateFavoriteStatus();
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(_isFavorite ? 'Added to Favorites' : 'Removed from Favorites'), duration: const Duration(seconds: 1)));
                    },
                    style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5), padding: const EdgeInsets.all(4.0)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4.0)),
                    child: Text('${voteAverage.toStringAsFixed(1)}/10', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(_isInWatchlist ? Icons.bookmark : Icons.bookmark_border, color: _isInWatchlist ? Colors.green : Colors.white, size: 20),
                    onPressed: () async {
                      if (_userDataService == null) return;
                      await _userDataService!.toggleWatchlistMovie(mikoMovie.id); // Assuming this method exists
                      _updateWatchlistStatus();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isInWatchlist ? 'Added to Watchlist' : 'Removed from Watchlist'), duration: const Duration(seconds: 1)));
                    },
                    style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5), padding: const EdgeInsets.all(4.0)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: AppColors.dividerColor.withOpacity(0.5), height: 1.0)),
    );
  }
  
  Widget _buildMikoBasicInfoSection(BuildContext context, MikoMovie.Movie mikoMovie, {TmdbApi.Movie? tmdbMovie, bool showTmdbRating = true}) {
    final posterUrl = mikoMovie.getPosterUrl() ?? tmdbMovie?.fullPosterPath;
    final title = mikoMovie.title;
    final tagline = mikoMovie.tagline ?? tmdbMovie?.tagline;
    
    String releaseYearDisplay = 'N/A';
    if (tmdbMovie?.releaseDate != null && tmdbMovie!.releaseDate.isNotEmpty) {
      try { releaseYearDisplay = DateFormat('yyyy').format(DateTime.parse(tmdbMovie.releaseDate)); } catch (e) { /* Handle error or use mikoMovie.releaseDate */ }
    } else if (mikoMovie.releaseDate != null) {
      releaseYearDisplay = DateFormat('yyyy').format(mikoMovie.releaseDate!);
    }

    final runtime = mikoMovie.runtime ?? tmdbMovie?.runtime;
    final genresToDisplay = mikoMovie.genres.isNotEmpty ? mikoMovie.genres : (tmdbMovie?.genres?.map((g) => g.name).toList() ?? []);
    
    final tmdbVoteAverage = tmdbMovie?.voteAverage ?? mikoMovie.voteAverage; // Prioritize TMDB if available
    final tmdbVoteCount = tmdbMovie?.voteCount ?? mikoMovie.voteCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (posterUrl != null)
            Hero(
              tag: 'movie-${mikoMovie.id}', // Use MikoMovie's id
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 120, height: 180,
                  child: CachedNetworkImage(
                    imageUrl: posterUrl, fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.secondaryBackground),
                    errorWidget: (context, url, error) => Container(color: AppColors.secondaryBackground, child: const Icon(Icons.movie_creation_outlined, color: AppColors.secondaryText)),
                  )
                )
              ),
            )
          else
            Container(width: 120, height: 180, color: AppColors.secondaryBackground, child: const Icon(Icons.movie_creation_outlined, color: AppColors.secondaryText)),
          
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                if (tagline != null && tagline.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"$tagline"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[400])),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(releaseYearDisplay, style: const TextStyle(color: AppColors.secondaryText)),
                  const SizedBox(width: 10),
                  if (runtime != null && runtime > 0) ...[
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 4),
                    Text(tmdbMovie != null ? tmdbMovie.formattedRuntime : '$runtime min', style: const TextStyle(color: AppColors.secondaryText)),
                  ]
                ]),
                if (showTmdbRating) ... [
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20), const SizedBox(width: 4),
                    Text('${tmdbVoteAverage.toStringAsFixed(1)} (${tmdbVoteCount} votes)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                  ]),
                ],
                const SizedBox(height: 10),
                if (genresToDisplay.isNotEmpty)
                  Wrap(
                    spacing: 6.0, runSpacing: 4.0,
                    children: genresToDisplay.map((genre) => Chip(
                      label: Text(genre, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.chipBackground,
                      labelStyle: const TextStyle(color: AppColors.chipText),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildMovieDetailsBody(
    BuildContext context,
    MikoMovie.Movie mikoMovie,
    TmdbApi.Movie? tmdbDetailedMovie,
    TmdbApi.MovieCredits? credits,
    TmdbApi.MovieResponse? recommendations) {

    final String overview = tmdbDetailedMovie?.overview ?? mikoMovie.overview;
    final List<String> downloadLinks = mikoMovie.getDownloadLinksList();
    final bool showDetailedTmdbInfo = tmdbDetailedMovie != null && credits != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMikoBasicInfoSection(context, mikoMovie, tmdbMovie: tmdbDetailedMovie),
          const SizedBox(height: 24),

          // Miko's Play/Download Buttons (Already have logic from Miko's original page)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if(mikoMovie.parseVideoData().isNotEmpty) // Show play trailer if videos exist
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.local_movies), // Or Icons.movie_filter
                    label: const Text('Trailer'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor, foregroundColor: AppColors.primaryText, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    onPressed: () => _showVideoSelectionDialog(context, mikoMovie),
                  ),
                ),
              if(mikoMovie.parseVideoData().isNotEmpty && downloadLinks.isNotEmpty)
                const SizedBox(width: 10), // Spacer if both buttons shown

              if(downloadLinks.isNotEmpty) // Your existing Play/Stream button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor, foregroundColor: AppColors.primaryText, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                    onPressed: () => _showDownloadLinkSelection(context, downloadLinks, mikoMovie.title),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if(downloadLinks.isNotEmpty) // Your existing Download button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download Sources'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryBackground, foregroundColor: AppColors.primaryText, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: () => _realDownloadinglink(context, downloadLinks, mikoMovie.title),
              ),
            ),
          const SizedBox(height: 24),
          
          Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 8),
          Text(overview.isEmpty ? 'No overview available.' : overview, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText, height: 1.4)),
          const SizedBox(height: 24),

          _buildDetailSectionFromMiko('Keywords', mikoMovie.keywords.join(', ')),

          if (showDetailedTmdbInfo) ...[
            if (credits!.directors.isNotEmpty) ...[
              Text('Director${credits.directors.length > 1 ? 's' : ''}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
              const SizedBox(height: 4),
              Text(credits.directors.map((director) => director.name).join(', '), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
              const SizedBox(height: 16),
            ],
            if (credits.cast.isNotEmpty) _buildCastSection(context, credits.cast.take(10).toList()),
            if (credits.directors.isNotEmpty) _buildCrewSection(context, "Directors", credits.directors),
            if (credits.writers.isNotEmpty) _buildCrewSection(context, "Writers", credits.writers.take(5).toList()),
            _buildProductionInfoSection(context, tmdbDetailedMovie!),
            if (recommendations != null && recommendations.results.isNotEmpty) _buildRecommendationsSection(context, recommendations),
          ] else if (tmdbDetailedMovie == null) ... [
            const Center(child: Text("More details could not be loaded.", style: TextStyle(color: AppColors.secondaryText))),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildDetailSectionFromMiko(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  void _navigateToPersonDetail(int personId, String name, String? profilePath) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PersonDetailPage(personId: personId, initialName: name, initialProfilePath: profilePath)));
  }

  Widget _buildCastSection(BuildContext context, List<TmdbApi.Cast> castList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Cast', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190, // Increased height slightly
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: castList.length,
            itemBuilder: (context, index) {
              final castMember = castList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => _navigateToPersonDetail(castMember.id, castMember.name, castMember.profilePath),
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'person-${castMember.id}',
                          child: Material(
                            elevation: 2, borderRadius: BorderRadius.circular(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 100, height: 100,
                                child: castMember.profilePath != null
                                  ? CachedNetworkImage(imageUrl: castMember.fullProfilePath, fit: BoxFit.cover, errorWidget: (context, url, error) => _placeholderPersonIcon())
                                  : _placeholderPersonIcon(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(castMember.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryText)),
                        const SizedBox(height: 2),
                        Text(castMember.character, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _placeholderPersonIcon() {
    return Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person, size: 40, color: AppColors.secondaryText));
  }

  Widget _buildCrewSection(BuildContext context, String title, List<TmdbApi.Crew> crewList) {
    if (crewList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: crewList.map((member) {
            return GestureDetector(
              onTap: () => _navigateToPersonDetail(member.id, member.name, member.profilePath),
              child: Chip(
                avatar: member.profilePath != null ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(member.fullProfilePath)) : CircleAvatar(backgroundColor: Colors.grey[700], child: const Icon(Icons.person, size: 16)),
                label: Text('${member.name} (${member.job})', style: const TextStyle(color: AppColors.chipText)),
                backgroundColor: AppColors.chipBackground,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductionInfoSection(BuildContext context, TmdbApi.Movie tmdbMovie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tmdbMovie.productionCompanies != null && tmdbMovie.productionCompanies!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Production Companies', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tmdbMovie.productionCompanies!.length,
              itemBuilder: (context, index) {
                final company = tmdbMovie.productionCompanies![index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      if (company.logoPath != null)
                        CachedNetworkImage(imageUrl: company.fullLogoPath, height: 40, width: 80, fit: BoxFit.contain, errorWidget: (context, _, __) => _companyPlaceholder(company.name, isLogo: true))
                      else
                        _companyPlaceholder(company.name, isLogo: false),
                      const SizedBox(height: 4),
                      SizedBox(width: 80, child: Text(company.name, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        if (tmdbMovie.budget != null || tmdbMovie.revenue != null) ...[
          const SizedBox(height: 16),
          Row(children: [
            if (tmdbMovie.budget != null && tmdbMovie.budget! > 0) ...[
              Expanded(child: _buildInfoCard(context, 'Budget', tmdbMovie.formattedBudget, Icons.attach_money)), const SizedBox(width: 16)],
            if (tmdbMovie.revenue != null && tmdbMovie.revenue! > 0)
              Expanded(child: _buildInfoCard(context, 'Revenue', tmdbMovie.formattedRevenue, Icons.trending_up)),
          ]),
        ],
      ],
    );
  }

  Widget _companyPlaceholder(String name, {required bool isLogo}) {
    return Container(height: 40, width: 80, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)), child: Center(child: Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 2, overflow: TextOverflow.ellipsis)));
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      color: AppColors.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.accentColor), const SizedBox(height: 6),
            Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.secondaryText)), const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, TmdbApi.MovieResponse recommendations) {
    if (recommendations.results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text('Recommendations', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText))),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Removed horizontal padding to align with outer padding
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.results.length > 10 ? 10 : recommendations.results.length,
            itemBuilder: (context, index) {
              final tmdbApiMovie = recommendations.results[index];
              // Convert TMDB API Movie to your MikoMovie.Movie for the card
              final MikoMovie.Movie mikoStyleRecommendationMovie = MikoMovie.Movie.fromTmdbResponseMovie(tmdbApiMovie);
              return _buildRecommendationCard(context, mikoStyleRecommendationMovie);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, MikoMovie.Movie mikoMovie) {
    final posterUrl = mikoMovie.getPosterUrl();
    return GestureDetector(
      onTap: () {
        // Important: Ensure the new page gets a MikoMovie.Movie object.
        // If it was created from a TMDB recommendation, it might lack download links etc.
        // You might need to fetch the *full* MikoMovie.Movie object from your provider if necessary.
        // For now, assuming the converted mikoMovie is sufficient for display.
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MergedMovieDetailPage(movie: mikoMovie)));
      },
      child: Container(
        width: 130, margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 170, width: 130,
                child: posterUrl != null
                  ? CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover, errorWidget: (context, _, __) => _movieCardPlaceholder())
                  : _movieCardPlaceholder(),
              )
            ),
            const SizedBox(height: 4),
            Text(mikoMovie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            Text(mikoMovie.releaseDate != null ? DateFormat('yyyy').format(mikoMovie.releaseDate!) : 'N/A', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _movieCardPlaceholder() {
    return Container(height: 170, width: 130, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.movie_outlined, size: 40, color: AppColors.secondaryText)));
  }
}