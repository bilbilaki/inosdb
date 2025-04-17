// lib/screens/movie_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/screens/video_player_screen.dart'; // For MediaKit player
import 'package:myapp/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({required this.movieId, super.key});

  @override
  Widget build(BuildContext context) {
    // Find the movie using the provider
    final movie = Provider.of<MovieProvider>(context, listen: false).getMovieById(movieId);

    if (movie == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('Movie not found!', style: TextStyle(color: AppColors.secondaryText)),
        ),
      );
    }

    final backdropUrl = movie.getBackdropUrl();
    final posterUrl = movie.getPosterUrl();
    final downloadLinks = movie.getDownloadLinksList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, // Height of the backdrop
            pinned: true, // Keep AppBar visible when scrolling up
            backgroundColor: AppColors.secondaryBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: const TextStyle(fontSize: 16.0, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: false, // Align title to start
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16), // Adjust padding
              background: backdropUrl != null
                  ? Stack(
                     fit: StackFit.expand,
                       children:[
                            CachedNetworkImage(
                              imageUrl: backdropUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.secondaryBackground),
                              errorWidget: (context, url, error) => Container(
                                  color: AppColors.secondaryBackground,
                                  child: posterUrl != null
                                      ? CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.contain) // Fallback to poster
                                      : const Icon(Icons.movie_outlined, size: 100, color: AppColors.secondaryText)
                                  ),
                            ),
                           // Add a gradient overlay for better title readability
                          Container(
                             decoration: BoxDecoration(
                                gradient: LinearGradient(
                                   begin: Alignment.topCenter,
                                   end: Alignment.bottomCenter,
                                   colors: [
                                     Colors.transparent,
                                     Colors.black.withOpacity(0.2),
                                     AppColors.primaryBackground.withOpacity(0.9),
                                     AppColors.primaryBackground,
                                   ],
                                    stops: const [0.0, 0.5, 0.9, 1.0]
                                ),
                             ),
                           )
                       ]
                  )
                  : Container(color: AppColors.secondaryBackground, child: Center(child: Text(movie.title, style: const TextStyle(color: AppColors.primaryText, fontSize: 24)))),
            ),
             // Optional: Add subtle border when pinned
            bottom: PreferredSize(                       // Add this code to get bottom border
               preferredSize: const Size.fromHeight(1.0), // Creates the border size
               child: Container(                           // Creates the border container
                  color: AppColors.dividerColor.withOpacity(0.5),
                  height: 1.0,
               )
            )
          ),

          // --- Movie Content Below AppBar ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title and Basic Info Row ---
                  Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small Poster on the side
                       if (posterUrl != null)
                         SizedBox(
                            width: 100,
                            child: ClipRRect(
                               borderRadius: BorderRadius.circular(8),
                               child: CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover)
                            )
                         )
                       else Container(width: 100, height: 150, color: AppColors.secondaryBackground),

                       const SizedBox(width: 16),

                       Expanded(
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Text(
                                     movie.title,
                                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                                  ),
                                  if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                                     const SizedBox(height: 4),
                                     Text(
                                        movie.tagline!,
                                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.secondaryText),
                                     ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                      children: [
                                         const Icon(Icons.star, color: Colors.amber, size: 18),
                                         const SizedBox(width: 4),
                                         Text('${movie.voteAverage.toStringAsFixed(1)}/10', style: const TextStyle(color: AppColors.primaryText)),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.calendar_today, size: 16, color:AppColors.secondaryText),
                                         const SizedBox(width: 4),
                                         Text(movie.releaseDate != null ? DateFormat('yyyy').format(movie.releaseDate!) : 'N/A', style: const TextStyle(color: AppColors.secondaryText)),
                                          const SizedBox(width: 10),
                                          if (movie.runtime != null) ...[
                                            const Icon(Icons.timer_outlined, size: 16, color:AppColors.secondaryText),
                                           const SizedBox(width: 4),
                                           Text('${movie.runtime} min', style: const TextStyle(color: AppColors.secondaryText)),
                                        ]
                                      ],
                                  ),
                                   const SizedBox(height: 10),
                                  Wrap( // Display Genres as chips
                                     spacing: 6.0,
                                     runSpacing: 4.0,
                                     children: movie.genres.map((genre) => Chip(
                                        label: Text(genre, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: AppColors.chipBackground,
                                        labelStyle: const TextStyle(color: AppColors.chipText),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                     )).toList(),
                                  ),

                               ]
                           )
                       )
                    ]
                  ),
                  const SizedBox(height: 24),

                  // --- Play and Download Buttons ---
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                        ElevatedButton.icon(
                           icon: const Icon(Icons.play_arrow),
                           label: const Text('Play'),
                           style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentColor,
                              foregroundColor: AppColors.primaryText,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                           ),
                           onPressed: downloadLinks.isEmpty
                             ? null // Disable if no links
                             : () => _showDownloadLinkSelection(context, downloadLinks),
                        ),
                          ElevatedButton.icon(
                           icon: const Icon(Icons.download_outlined),
                           label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBackground, // Different style
                              foregroundColor: AppColors.primaryText,
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12)
                           ),
                           onPressed: () {
                               // TODO: Implement actual download logic
                               ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text('Download not implemented yet.'), duration: Duration(seconds: 2))
                               );
                           },
                        ),
                     ],
                  ),
                  const SizedBox(height: 24),

                  // --- Overview / Synopsis ---
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // --- Additional Details (Optional) ---
                   _buildDetailSection('Keywords', movie.keywords.join(', ')),
                   _buildDetailSection('Production Countries', movie.productionCountries.join(', ')),

                  const SizedBox(height: 50), // Add some padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

   // Helper to build sections for additional details
  Widget _buildDetailSection(String title, String content) {
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


  // --- Function to show Download Link Selection Dialog ---
  void _showDownloadLinkSelection(BuildContext context, List<String> links) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Select Quality / Source'),
          titleTextStyle: const TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
          backgroundColor: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: links.map((link) {
            // Try to guess quality from URL (very basic)
            String qualityGuess = "Unknown";
            if (link.contains('1080p')) {
              qualityGuess = "1080p";
            } else if (link.contains('720p')) qualityGuess = "720p";
            else if (link.contains('480p')) qualityGuess = "480p";
             else if (link.contains('BluRay')) qualityGuess += " BluRay";
              else if (link.contains('HEVC') || link.contains('x265')) qualityGuess += " HEVC";
               else if (link.contains('x264')) qualityGuess += " x264";


            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
                // Navigate to the Video Player Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(videoUrl: link),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Text(
                '$qualityGuess - ${Uri.parse(link).host}', // Show quality guess and domain
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}