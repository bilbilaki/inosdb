import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/models/season.dart';
import 'package:myapp/models/tv_series.dart'; // Import VideoInfo
import 'package:myapp/services/user_data_service.dart'; // Import UserDataService
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/utils/colors.dart';
import 'package:myapp/widgets/episode_tile.dart';
import 'package:intl/intl.dart';
class TvSeriesDetailsScreen extends StatelessWidget {
 final int tvSeriesId;

 const TvSeriesDetailsScreen({required this.tvSeriesId, super.key});

  // --- Function to show Trailer Selection Dialog ---
 void _showVideoSelectionDialog(BuildContext context, TvSeries series) {
    final List<VideoInfo> videos = series.parseVideoData();
    if (videos.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trailers or clips found.'), duration: Duration(seconds: 2)),
       );
      return;
    }
    showDialog( /* ... identical dialog logic as in MovieDetailsScreen ... */
       context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Trailers & Clips'), /* ... */
          children: videos.map((video) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                series.launchVideo(video.key); // Call launchVideo on TvSeries object
              },
              /* ... rest of SimpleDialogOption */
              child: Row( /* ... icon, text ... */ ),
            );
          }).toList(),
       );
       },
    );
 }
  @override
  Widget build(BuildContext context) {
    // Fetch the specific series using the ID directly from the provider's map/list
    // No 'listen: false' needed if the UI should rebuild if the underlying data changes (unlikely here)
    final series = Provider.of<TvSeriesProvider>(context).getTvSeriesByTmdbId(tvSeriesId);

    if (series == null) {
      // Handle case where series with the ID isn't found (shouldn't happen if navigation is correct)
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: const Text('Not Found'),
          backgroundColor: AppColors.secondaryBackground,
           iconTheme: const IconThemeData(color: AppColors.primaryText), // Ensure back button is visible
           titleTextStyle: const TextStyle(color: AppColors.primaryText, fontSize: 20),
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
    final releaseYear = series.firstAirDate != null ? DateFormat('yyyy').format(series.firstAirDate!) : 'N/A';

    // Format runtime if available
    final runtimeString = series.runtime != null && series.runtime! > 0 ? '${series.runtime} min/ep' : 'N/A';

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
             iconTheme: const IconThemeData(color: AppColors.primaryText), // Ensure icons are visible
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                series.name, // Use the name from CSV
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  shadows: [Shadow(blurRadius: 4.0, color: Colors.black87, offset: Offset(1, 1))]), // Enhanced shadow
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
               ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              background: Stack(
                fit: StackFit.expand,
                 children: [
                   // Backdrop Image
                   backdropUrl != null
                      ? CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: AppColors.secondaryBackground),
                          errorWidget: (context, url, error) => Container(
                              color: AppColors.secondaryBackground,
                              child: const Icon(Icons.broken_image, color: AppColors.secondaryText, size: 60)),
                        )
                      : Container( // Fallback color if no backdrop
                         color: AppColors.secondaryBackground,
                         child: posterUrl != null // Try poster as fallback background
                             ? CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.contain, alignment: Alignment.center)
                             : const Center(child: Icon(Icons.tv, size: 100, color: AppColors.secondaryText)),
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
                           stops: const [0.0, 0.5, 0.9, 1.0], // Adjust stops for desired effect
                          ),
                       ),
                    ),
                 ],
              ),
              stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle], // Optional effects
            ),
            // Optional: Add subtle border when pinned
             bottom: PreferredSize(
               preferredSize: const Size.fromHeight(1.0),
               child: Container(
                 color: AppColors.dividerColor.withOpacity(0.5),
                 height: 1.0,
                )
             )
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
                          SizedBox(
                             width: 110, // Slightly wider maybe
                             child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: posterUrl != null
                                    ? CachedNetworkImage(
                                      imageUrl: posterUrl,
                                      fit: BoxFit.cover, // Use cover
                                      height: 165, // Explicit height based on 2/3 aspect ratio
                                      placeholder: (context, url) => Container(height: 165, width: 110, color: AppColors.secondaryBackground),
                                      errorWidget: (context, url, error) => const SizedBox(height: 165, width: 110, child: Icon(Icons.error)),
                                     )
                                    : Container(
                                      height: 165,
                                      width: 110,
                                      decoration: BoxDecoration(
                                         color: AppColors.secondaryBackground,
                                         borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.tv, size: 50, color: AppColors.secondaryText)),
                              ),
                           ),

                          const SizedBox(width: 16),

                          // Core Details Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(series.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold)), // Use a larger title here
                                // If original name differs and is useful, display it
                                if (series.originalName.isNotEmpty && series.originalName.toLowerCase() != series.name.toLowerCase())
                                   Padding(
                                     padding: const EdgeInsets.only(top: 4.0),
                                     child: Text(series.originalName, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.secondaryText)),
                                   ),
                                const SizedBox(height: 8),
                                // Info Row (Rating, Year, Runtime, Status)
                                Wrap(
                                  spacing: 10.0, // Horizontal gap
                                  runSpacing: 6.0,  // Vertical gap if wraps
                                  children: [
                                    _buildInfoChip(Icons.star, '${series.voteAverage.toStringAsFixed(1)} (${series.voteCount})', Colors.amber),
                                    _buildInfoChip(Icons.calendar_today, releaseYear, AppColors.secondaryText),
                                    if (series.runtime != null && series.runtime! > 0)
                                       _buildInfoChip(Icons.timer_outlined, runtimeString, AppColors.secondaryText),
                                     _buildInfoChip(Icons.info_outline, series.status, AppColors.secondaryText),
                                  ],
                                ),

                                const SizedBox(height: 10),
                                // Genres Chips
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: series.genres
                                      .map((genre) => Chip(
                                            label: Text(genre),
                                            backgroundColor: AppColors.chipBackground, // Use AppColors
                                            labelStyle: const TextStyle(fontSize: 11, color: AppColors.chipText), // Use AppColors
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            visualDensity: VisualDensity.compact,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            side: BorderSide.none,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 24), // Increased spacing

                      // --- Overview ---
                      if (series.overview.isNotEmpty) ...[
                          Text('Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            series.overview,
                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 14, height: 1.5), // Slightly adjusted line height
                         ),
                         const SizedBox(height: 24),
                      ],


                     // --- Keywords (Optional) ---
                      if (series.keywords.isNotEmpty) ...[
                         Text('Keywords', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                           Wrap(
                             spacing: 6.0,
                             runSpacing: 4.0,
                             children: series.keywords
                               .map((keyword) => Chip(
                                  label: Text(keyword),
                                  backgroundColor: AppColors.secondaryBackground.withOpacity(0.7),
                                  labelStyle: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  visualDensity: VisualDensity.compact,
                                 ))
                                .toList(),
                           ),
                           const SizedBox(height: 24),
                       ],

                       // --- Seasons and Episodes Section ---
                       Text('Episodes', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold)), // Larger heading
                       const SizedBox(height: 8),
                       if (series.seasons.isEmpty)
                         const Padding(
                           padding: EdgeInsets.only(top: 16.0),
                           child: Text(
                             'No episode information found for this series in the database.',
                             style: TextStyle(color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                           ),
                         )
                       else
                         _buildSeasonsList(context, series.seasons), // Use helper


                      const SizedBox(height: 40), // More bottom padding
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

   // Helper widget for small info chips (Rating, Year, etc.)
   Widget _buildInfoChip(IconData icon, String text, Color iconColor) {
      return Row(
        mainAxisSize: MainAxisSize.min, // Prevent row from expanding
        children: [
           Icon(icon, size: 16, color: iconColor),
           const SizedBox(width: 4),
           Text(text, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
        ],
      );
   }


  // Helper Widget to build the list of seasons with ExpansionTiles
  Widget _buildSeasonsList(BuildContext context, List<Season> seasons) {
    // If there's only one season, maybe don't use ExpansionTile or expand it by default
    bool defaultExpansion = seasons.length == 1;

    return ListView.builder(
       shrinkWrap: true, // Essential inside CustomScrollView/SliverList
       physics: const NeverScrollableScrollPhysics(), // Disable nested scrolling
       itemCount: seasons.length,
       itemBuilder: (context, index) {
         final season = seasons[index];
         // Use ExpansionTile for collapsable seasons
         return Card( // Wrap ExpansionTile in a Card for better visual separation
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            color: AppColors.secondaryBackground.withOpacity(0.4), // Slightly transparent background
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias, // Ensures content respects border radius
            child: ExpansionTile(
              key: PageStorageKey('season_${season.seasonNumber}'), // Maintain expansion state
               title: Text(
                 'Season ${season.seasonNumber}',
                 style: const TextStyle(
                     color: AppColors.primaryText,
                     fontWeight: FontWeight.w600,
                     fontSize: 16),
               ),
               subtitle: Text(
                  '${season.episodes.length} Episode${season.episodes.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
               ),
               iconColor: AppColors.accentColor, // Use accent color for expand icon
               collapsedIconColor: AppColors.secondaryText,
               // Expand first season or if only one season exists
               initiallyExpanded: defaultExpansion || season.seasonNumber == 1, // Keep first season expanded usually
               childrenPadding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4), // Padding for episode tiles
               // Remove default dividers and use padding/margin on EpisodeTile instead
               // children: season.episodes.map((episode) => EpisodeTile(episode: episode)).toList(),
                children: ListTile.divideTiles( // Add subtle dividers between episodes
                  context: context,
                  color: AppColors.dividerColor.withOpacity(0.3),
                  tiles: season.episodes.map((episode) => EpisodeTile(episode: episode)),
               ).toList(),
             ),
          );
       },
      );
   }
 }