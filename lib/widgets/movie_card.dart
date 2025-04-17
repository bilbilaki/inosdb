// lib/widgets/movie_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/screens/movie_details_screen.dart'; // Navigate to details
import 'package:myapp/utils/colors.dart';

// For date formatting

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({required this.movie, super.key});

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.getPosterUrl();
    final releaseYear = movie.releaseDate?.year.toString() ?? 'N/A';

    return InkWell(
      onTap: () {
        // Navigate to Movie Details Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(movieId: movie.id), // Pass movie ID
          ),
        );
      },
      child: Card(
          color: Colors.transparent, // Make card transparent, container handles bg
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster using CachedNetworkImage
              AspectRatio(
                aspectRatio: 2 / 3, // Common poster aspect ratio
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(8.0),
                   child: posterUrl != null
                    ? CachedNetworkImage(
                        imageUrl: posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.secondaryBackground,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentColor)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.secondaryBackground,
                           child: const Center(child: Icon(Icons.error_outline, color: AppColors.secondaryText))
                        ),
                      )
                    : Container( // Placeholder if no poster
                        color: AppColors.secondaryBackground,
                          child:  const Center(child: Icon(Icons.movie_filter_outlined, color: AppColors.secondaryText, size: 40))
                      ),
                )
              ),
               const SizedBox(height: 8.0),

              // Movie Info
              Padding(
                padding:  const EdgeInsets.symmetric(horizontal: 4.0), // Reduced padding for grid
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        style:  const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0, // Slightly smaller for grid
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
                            style:  const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      ),
                    ],
                  )
              ),
             // Removed the channel avatar/more icon section from VideoCard
             const SizedBox(height: 8.0), // Space below card
            ],
          ),
      )
    );
  }
}