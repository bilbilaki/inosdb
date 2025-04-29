import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:miko/models/movie.dart';
import 'package:miko/screens/movie_details_screen.dart';
//import 'package:myapp/screens/movie_details_screen.dart'; // Navigate to details
import 'package:miko/utils/colors.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:provider/provider.dart'; // For accessing UserDataService

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MovieDetailsScreen(movieId: movie.id), // Pass movie ID
          ),
        );
        //context.go('/movie/${movie.id}');
      },
      child: Card(
        color: AppColors2
            .blackbackground, // Make card transparent, container handles bg
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster using CachedNetworkImage with Buttons
            AspectRatio(
              aspectRatio: 2 / 3,

              // Common poster aspect ratio
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors2.onSurface,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors2.accentColor,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors2.onSecondary,
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: AppColors2.error,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            // Placeholder if no poster
                            color: AppColors2.onBackground,
                            child: const Center(
                              child: Icon(
                                Icons.movie_filter_outlined,
                                color: AppColors2.error,
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
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color.fromARGB(255, 255, 17, 0)
                                : Colors.white,
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
                            color: isInWatchlist
                                ? const Color.fromARGB(255, 65, 220, 38)
                                : Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            await userDataService
                                .toggleWatchlistMovie(movie.id);
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
                            backgroundColor: AppColors2.onSurface
                                .withOpacity(0.5), // Cute backdrop
                            padding: const EdgeInsets.all(0.5),
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
                      color: AppColors2.onPrimary,
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
                      const SizedBox(width: 2),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)} • $releaseYear',
                        style: const TextStyle(
                          color: AppColors2.tinytext,
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
                      color: AppColors2.tinytext,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Language: ${movie.originalLanguage.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors2.tinytext,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Popularity: ${movie.popularity.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: AppColors2.tinytext,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2.0), // Space below card
          ],
        ),
      ),
    );
  }
}
