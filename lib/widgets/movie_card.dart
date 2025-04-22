import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/movie.dart';
  //import 'package:myapp/screens/movie_details_screen.dart'; // Navigate to details
import 'package:myapp/utils/colors.dart';
import 'package:myapp/services/user_data_service.dart';
import 'package:provider/provider.dart'; // For accessing UserDataService
import 'package:myapp/router.dart';
import 'package:go_router/go_router.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({required this.movie, super.key});

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.getPosterUrl();
    final releaseYear = movie.releaseDate?.year.toString() ?? 'N/A';
    final userDataService = Provider.of<UserDataService>(context);

    // Check if the movie is in Favorites or Watchlist
    bool isFavorite = userDataService.isFavoriteMovie(movie.id);
    bool isInWatchlist = userDataService.isOnWatchlistMovie(movie.id);

    return InkWell(
      onTap: () {
        // Navigate to Movie Details Screen
        //  Navigator.push(
        //  context,
        //  MaterialPageRoute(
        //    builder: (_) => MovieDetailsScreen(movieId: movie.id), // Pass movie ID
        //  ),
        //);
        context.go('/movie/${movie.id}');
      },
      child: Card(
        color: Colors.transparent, // Make card transparent, container handles bg
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster using CachedNetworkImage with Buttons
            AspectRatio(
              aspectRatio: 2 / 3, // Common poster aspect ratio
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.secondaryBackground,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.secondaryBackground,
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            // Placeholder if no poster
                            color: AppColors.secondaryBackground,
                            child: const Center(
                              child: Icon(
                                Icons.movie_filter_outlined,
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
                            await userDataService.toggleFavoriteMovie(movie.id);
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
                            color: isInWatchlist ? Colors.green : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService.toggleWatchlistMovie(movie.id);
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
            const SizedBox(height: 8.0),

            // Movie Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)} • $releaseYear',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  // Additional Info: Runtime, Language, Popularity
                  Text(
                    'Runtime: ${movie.runtime != null ? "${movie.runtime} min" : 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Language: ${movie.originalLanguage.toUpperCase() ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Popularity: ${movie.popularity.toStringAsFixed(1) ?? 'N/A'}',
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
            const SizedBox(height: 8.0), // Space below card
          ],
        ),
      ),
    );
  }
}