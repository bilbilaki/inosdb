// lib/screens/tv_series_details_screen.dart
import 'package:flutter/material.dart';
import 'package:miko/models/season_anime.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Import TvSeries
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/utils/colors.dart';
import 'package:miko/widgets/anime_episodes_tile.dart'; // Import EpisodeTile
import 'package:intl/intl.dart'; // For formatting dates

class AnimeDetailsScreen extends StatelessWidget {
  final int tvSeriesId; // Use TMDB ID to fetch from map

  const AnimeDetailsScreen({required this.tvSeriesId, super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the specific series using the ID directly from the provider's map/list
    // No 'listen: false' needed if the UI should rebuild if the underlying data changes (unlikely here)
    final series =
        Provider.of<AnimeProvider>(context).getAnimeByTmdbId(tvSeriesId);
    final userDataService = Provider.of<UserDataService>(context);
    if (series == null) {
      // Handle case where series with the ID isn't found (shouldn't happen if navigation is correct)
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: const Text('Not Found'),
          backgroundColor: AppColors.secondaryBackground,
          iconTheme: const IconThemeData(
              color: AppColors.primaryText), // Ensure back button is visible
          titleTextStyle:
              const TextStyle(color: AppColors.primaryText, fontSize: 20),
        ),
        body: const Center(
          child: Text(
            'TV Series details not found.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    // Use data directly from the `series` object loaded from CSV
    final backdropUrl = series.fullBackdropUrl;
    final posterUrl = series.fullPosterUrl;
    final releaseYear = series.firstAirDate != null
        ? DateFormat('yyyy').format(series.firstAirDate!)
        : 'N/A';
    bool isFavorite = userDataService.isFavoriteAnime(series.tmdbId);
    bool isInWatchlist = userDataService.isOnWatchlistAnime(series.tmdbId);
    // Format runtime if available
    final runtimeString = series.runtime != null && series.runtime! > 0
        ? '${series.runtime} min/ep'
        : 'N/A';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: <Widget>[
          // --- App Bar with Backdrop ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true, // Optional: Allows overscroll stretch effect
            backgroundColor: AppColors.primaryBackground, // Base color
            iconTheme: const IconThemeData(
                color: AppColors.primaryText), // Ensure icons are visible
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                height: 1.0,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  backdropUrl != null
                      ? CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.secondaryBackground),
                          errorWidget: (context, url, error) => Container(
                              color: AppColors.secondaryBackground,
                              child: const Icon(Icons.broken_image,
                                  color: AppColors.secondaryText, size: 60)),
                        )
                      : Container(
                          // Fallback color if no backdrop
                          color: AppColors.secondaryBackground,
                          child: posterUrl !=
                                  null // Try poster as fallback background
                              ? CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center)
                              : const Center(
                                  child: Icon(Icons.tv,
                                      size: 100,
                                      color: AppColors.secondaryText)),
                        ),
                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          AppColors.primaryBackground.withOpacity(0.8),
                          AppColors.primaryBackground,
                        ],
                        stops: const [
                          0.0,
                          0.5,
                          0.9,
                          1.0
                        ], // Adjust stops for desired effect
                      ),
                    ),
                  ),
                  // Positioned widget moved inside the Stack
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Favorite
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService
                                .toggleFavoriteAnime(series.tmdbId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? 'Removed from Favorites'
                                      : 'Added to Favorites',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(4.0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Rating bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${series.voteAverage.toStringAsFixed(1)} (${series.voteCount})',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Watchlist
                        IconButton(
                          icon: Icon(
                            isInWatchlist
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isInWatchlist ? Colors.green : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService
                                .toggleWatchlistAnime(series.tmdbId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isInWatchlist
                                      ? 'Removed from Watchlist'
                                      : 'Added to Watchlist',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(4.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Main Content Area ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // --- Basic Info Section (Poster & Core Details) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      SizedBox(
                        width: 110,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: posterUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  fit: BoxFit.cover,
                                  height: 165,
                                  placeholder: (_, __) => Container(
                                    height: 165,
                                    width: 110,
                                    color: AppColors.secondaryBackground,
                                  ),
                                  errorWidget: (_, __, ___) => const SizedBox(
                                    height: 165,
                                    width: 110,
                                    child: Icon(Icons.error),
                                  ),
                                )
                              : Container(
                                  height: 165,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tv,
                                    size: 50,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Core Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              series.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (series.originalName.isNotEmpty &&
                                series.originalName.toLowerCase() !=
                                    series.name.toLowerCase())
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  series.originalName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            // small info chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildInfoChip(Icons.calendar_today,
                                    releaseYear, Colors.white),
                                _buildInfoChip(
                                    Icons.timer, runtimeString, Colors.white),
                                _buildInfoChip(
                                    Icons.check, series.status, Colors.green),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // genres
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              children: series.genres
                                  .map((g) => Chip(
                                        label: Text(g),
                                        backgroundColor:
                                            AppColors.chipBackground,
                                        labelStyle: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.chipText),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Overview ---
                if (series.overview.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text('Overview',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0),
                    child: Text(
                      series.overview,
                      style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                          height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // --- Keywords (Optional) ---
                if (series.keywords.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text('Keywords',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0),
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: series.keywords
                          .map((keyword) => Chip(
                                label: Text(keyword),
                                backgroundColor: AppColors.secondaryBackground
                                    .withOpacity(0.7),
                                labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // --- Seasons and Episodes Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text('Episodes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                if (series.seasons.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'No episode information found for this series in the database.',
                      style: TextStyle(
                          color: AppColors.secondaryText,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0),
                    child: _buildSeasonsList(context, series.seasons),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ========== PRIVATE HELPERS ================
  Widget _buildInfoChip(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonsList(BuildContext context, List<SeasonAnime> seasons) {
    final defaultExpansion = seasons.length == 1;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: seasons.length,
      itemBuilder: (ctx, i) {
        final s = seasons[i];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          color: AppColors.secondaryBackground.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: PageStorageKey('season_${s.seasonNumber}'),
            title: Text(
              'Season ${s.seasonNumber}',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${s.episodes.length} Episode${s.episodes.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
            iconColor: AppColors.accentColor,
            collapsedIconColor: AppColors.secondaryText,
            initiallyExpanded: defaultExpansion || s.seasonNumber == 1,
            childrenPadding:
                const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            children: ListTile.divideTiles(
              context: ctx,
              color: AppColors.dividerColor.withOpacity(0.3),
              tiles:
                  s.episodes.map((e) => AnimeEpisodeTile(episode: e)).toList(),
            ).toList(),
          ),
        );
      },
    );
  }
}
