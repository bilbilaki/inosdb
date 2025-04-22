// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/utils/colors.dart';
// Use Staggered Grid View for potentially better layout
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/widgets/movie_card.dart'; // Use MovieCard
import 'package:myapp/utils/dynamic_background.dart'; // For dynamic background

// Remove imports for dummy data, VideoCard, StatusBar, ChipBar if not used

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to MovieProvider changes
    return Consumer<MovieProvider>(
      
      builder: (context, movieProvider, child) {
        return DynamicBackground(
          
          // Use DynamicBackground for a dynamic effec
            
          
          child: _buildBody(context, movieProvider),

        );
      },
);
  }

  Widget _buildBody(BuildContext context, MovieProvider movieProvider) {
    if (movieProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
    }

    if (movieProvider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.error_outline, color: Colors.red, size: 50),
               const SizedBox(height: 10),
               Text(
                'Error loading movies: ${movieProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
               ElevatedButton(
                   onPressed: () => movieProvider.loadMovies(),
                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor),
                   child: const Text('Retry', style: TextStyle(color: AppColors.primaryText)),
               )
            ]
          )
        ),
      );
    }

    if (movieProvider.movies.isEmpty && movieProvider.searchQuery.isNotEmpty) {
      return Center(
          child: Text(
          'No results found for "${movieProvider.searchQuery}"',
           style: const TextStyle(color: AppColors.secondaryText, fontSize: 16)
          )
      );
    }

     if (movieProvider.movies.isEmpty) {
      return const Center(child: Text('No movies found.', style: TextStyle(color: AppColors.secondaryText)));
    }


    // --- Display Movies using a Grid ---
    // Using MasonryGridView for variable height potential, or simple GridView.count
    return MasonryGridView.count(
      padding: const EdgeInsets.all(5.0),
      crossAxisCount: 1*3, // Adjust number of 
      mainAxisSpacing: 3.0,
      controller: ScrollController(keepScrollOffset: false),
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(),
      crossAxisSpacing: 12.0,
      cacheExtent: 100,
      itemCount: movieProvider.movies.length,
      itemBuilder: (context, index) {
        final movie = movieProvider.movies[index];
        return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
            ),
            child: MovieCard(movie: movie));
      },
    );

    // Alternative: Simple fixed-height grid
    /*
    return GridView.builder(
       padding: const EdgeInsets.all(8.0),
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          childAspectRatio: (2 / 3.5), // Adjust aspect ratio (width / height)
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
       ),
       itemCount: movieProvider.movies.length,
       itemBuilder: (context, index) {
         final movie = movieProvider.movies[index];
         return MovieCard(movie: movie);
       },
    );
    */
  }
}