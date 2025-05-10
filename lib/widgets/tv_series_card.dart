// lib/widgets/tv_series_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:miko/models/tv_series.dart';
import 'package:miko/screens/tv_series_details_screen.dart';
//import 'package:miko/screens/tv_series_details_screen.dart'; // Correct screen
import 'package:miko/utils/colors.dart'; // Assuming AppColors exists
import 'package:intl/intl.dart'; // For date formatting
import 'package:miko/services/user_data_service.dart';
import 'package:provider/provider.dart'; // For accessing UserDataService

class TvSeriesCard extends StatelessWidget {
  final TvSeries series;

  const TvSeriesCard({required this.series, super.key});

  @override
  Widget build(BuildContext context) {
    final posterUrl = series.fullPosterUrl; // Use helper from TvSeries model
    final userDataService = Provider.of<UserDataService>(context);

    // Safely get the year
    String displayYear = 'N/A';
    if (series.firstAirDate != null) {
      try {
        displayYear = DateFormat('yyyy').format(series.firstAirDate!);
      } catch (_) {
        displayYear = series.firstAirDate!.toString().split('-').first;
      }
    } else if (series.tmdbId == 0) {
      displayYear = "Info Missing";
    }

    // Check if the series is in Favorites or Watchlist
    bool isFavorite = userDataService.isFavoriteTvSeries(series.tmdbId);
    bool isInWatchlist = userDataService.isOnWatchlistTvSeries(series.tmdbId);

    return InkWell(
      onTap: () {
        if (series.tmdbId != 0) {
          Navigator.push(
           context,
            MaterialPageRoute(
              builder: (_) => TvSeriesDetailsScreen(tvSeriesId: series.tmdbId, ),
          ),
          );
          //context.go('/tv/${series.tmdbId}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open series details: Missing ID.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: AppColors.secondaryBackground.withOpacity(0.3),
                      child: posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentColor,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.secondaryText,
                                  size: 30,
                                ),
                              ),
                              fadeInDuration:
                                  const Duration(milliseconds: 300),
                              fadeOutDuration:
                                  const Duration(milliseconds: 300),
                            )
                          : const Center(
                              child: Icon(
                                Icons.tv_off_outlined,
                                color: AppColors.secondaryText,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Positioned buttons on top of the poster
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Row(
                      children: [
                        // Favorite Button
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService
                                .toggleFavoriteTvSeries(series.tmdbId);
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
                            backgroundColor:
                                Colors.black.withOpacity(0.5), // Cute backdrop
                            padding: const EdgeInsets.all(4.0),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        // Watchlist Button
                        IconButton(
                          icon: Icon(
                            isInWatchlist
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isInWatchlist
                                ? Colors.green
                                : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService
                                .toggleWatchlistTvSeries(series.tmdbId);
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
                            backgroundColor:
                                Colors.black.withOpacity(0.5), // Cute backdrop
                            padding: const EdgeInsets.all(4.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    series.name,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3.0),
                  // Rating and Year
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${series.voteAverage.toStringAsFixed(1)} • $displayYear',
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  // Additional Info: Episodes, Seasons, Language
                  Text(
                    'Seasons: ${series.numberOfSeasons ?? 'N/A'} • Episodes: ${series.numberOfEpisodes ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Language: ${series.originalLanguage.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}