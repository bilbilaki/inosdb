// lib/screens/tv_series_details_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/season.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/episode_tile.dart'; // Import EpisodeTile

class TvSeriesDetailsScreen extends StatelessWidget {
  final int tvSeriesId; // Use TMDB ID to fetch

  const TvSeriesDetailsScreen({required this.tvSeriesId, super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the specific series using the ID from the provider
    final series = Provider.of<AnimeProvider>(context, listen: false)
        .getTvSeriesByTmdbId(tvSeriesId);

    if (series == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: const Text('Not Found'),
          backgroundColor: AppColors.secondaryBackground,
        ),
        body: const Center(
          child: Text(
            'TV Series details not found.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    // Dynamic background using backdrop
    final backdropUrl = series.fullBackdropUrl;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: <Widget>[
          // --- App Bar with Backdrop ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true, // Keep AppBar visible when scrolling
            backgroundColor: AppColors.primaryBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                series.name,
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)]),
              ),
              centerTitle: false, // Align title to the left usually
              titlePadding:
                  const EdgeInsets.only(left: 60, bottom: 16), // Adjust padding
              background: backdropUrl != null
                  ? CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.secondaryBackground),
                      errorWidget: (context, url, error) => Container(
                          color: AppColors.secondaryBackground,
                          child: const Icon(Icons.error,
                              color: AppColors.secondaryText)),
                      // Add a gradient overlay for better title visibility
                  
        color: AppColors.secondaryBackground.withOpacity(0.7),
                    )
                  : Container(
                      color: AppColors.secondaryBackground,
                      child: const Icon(Icons.tv,
                          size: 50, color: AppColors.secondaryText)),
            ),
          ),

          // --- Main Content Area ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // --- Basic Info Section ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for Poster and Core Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          if (series.fullPosterUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: series.fullPosterUrl!,
                                height: 150,
                                width: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    height: 150,
                                    width: 100,
                                    color: AppColors.secondaryBackground),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                        height: 150,
                                        width: 100,
                                        child: Icon(Icons.error)),
                              ),
                            )
                          else
                            Container(
                                height: 150,
                                width: 100,
                                color: AppColors.secondaryBackground,
                                child: const Icon(Icons.tv,
                                    size: 50, color: AppColors.secondaryText)),

                          const SizedBox(width: 16),

                          // Core Details Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(series.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            color: AppColors.primaryText,
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                        '${series.voteAverage.toStringAsFixed(1)} / 10',
                                        style: const TextStyle(
                                            color: AppColors.secondaryText,
                                            fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    'First Aired: ${series.firstAirDate ?? 'N/A'}',
                                    style: const TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 14)),
                                const SizedBox(height: 6),
                                Text('Status: ${series.status}',
                                    style: const TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(
                                    'Seasons: ${series.numberOfSeasons} • Episodes: ${series.numberOfEpisodes}',
                                    style: const TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 14)),
                                const SizedBox(height: 8),
                                Wrap(
                                  // Display Genres
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: series.genres
                                      .map((genre) => Chip(
                                            label: Text(genre.name),
                                            backgroundColor: AppColors
                                                .accentColor
                                                .withOpacity(0.3),
                                            labelStyle: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primaryText),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 0),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- Overview ---
                      Text('Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primaryText)),
                      const SizedBox(height: 8),
                      Text(
                        series.overview.isEmpty
                            ? 'No overview available.'
                            : series.overview,
                        style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 15,
                            height: 1.4),
                      ),

                      const SizedBox(height: 24),

                      // --- Seasons and Episodes Section ---
                      Text('Episodes',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primaryText)),
                      const SizedBox(height: 8),
                      if (series.seasons.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                              'No episode information available from CSV.',
                              style: TextStyle(color: AppColors.secondaryText)),
                        )
                      else
                        _buildSeasonsList(context, series.seasons),

                      const SizedBox(height: 30), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsList(BuildContext context, List<Season> seasons) {
    return ListView.builder(
      shrinkWrap: true, // Important inside SliverList/ScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for this list
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        return ExpansionTile(
          // Use ExpansionTile for collapsable seasons
          title: Text(
            'Season ${season.seasonNumber}',
            style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          iconColor: AppColors.secondaryText,
          collapsedIconColor: AppColors.secondaryText,
          initiallyExpanded:
              season.seasonNumber == 1, // Expand first season by default
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: season.episodes
              .map((episode) => EpisodeTile(episode: episode))
              .toList(),
        );
      },
    );
    // Alternative: Simple list without ExpansionTile
    /*
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: seasons.map((season) => Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Padding(
 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
 child: Text(
 'Season ${season.seasonNumber}',
 style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600, fontSize: 16),
 ),
 ),
 ...season.episodes.map((episode) => EpisodeTile(episode: episode)).toList(),
 ],
 )).toList(),
 );
 */
  }
}
