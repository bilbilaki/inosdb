// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/utils/colors.dart';
// Use Staggered Grid View for potentially better layout
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/widgets/movie_card.dart'; // Use MovieCard
//import 'package:miko/utils/dynamic_background.dart'; // For dynamic background
import 'package:miko/services/user_data_service.dart';
// Remove imports for dummy data, VideoCard, StatusBar, ChipBar if not used

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to MovieProvider changes
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        return _buildBody(context, movieProvider);
      },
    );
  }

  Widget _buildBody(BuildContext context, MovieProvider movieProvider) {
    final userData = Provider.of<UserDataService>(context);

    final gridSize = userData.gridSize.toInt();
    if (movieProvider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors2.accentColor));
    }

    if (movieProvider.hasError) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.all(1.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                'Error loading movies: ${movieProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors2.error),
              ),
              const SizedBox(height: 10),
              // Example: Button to load movies (remove if data loads automatically)
              // This button is likely no longer needed as data loads on provider init
              // ElevatedButton(
              //   onPressed: () => movieProvider.loadMoviesFromDatabase(),
              //   style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors2.accentColor, // Use AppColors2 if defined, otherwise AppColors
              //       foregroundColor: AppColors2.primaryText,
              //   ),
              //   child: const Text('Load Movies'),
              // ),
            ])),
      );
    }

    if (movieProvider.movies.isEmpty && movieProvider.searchQuery.isNotEmpty) {
      return Center(
          child: Text('No results found for "${movieProvider.searchQuery}"',
              style: const TextStyle(color: AppColors2.error2, fontSize: 16)));
    }

    if (movieProvider.movies.isEmpty) {
      return const Center(
          child: Text('No movies found.',
              style: TextStyle(color: AppColors2.error)));
    }

    // --- Display Movies using a Grid ---
    // Using MasonryGridView for variable height potential, or simple GridView.count
    return MasonryGridView.count(
        padding: const EdgeInsets.all(5.0),
        crossAxisCount: 1 * gridSize, // Adjust number of
        mainAxisSpacing: 0.5,
        controller: ScrollController(keepScrollOffset: true),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        crossAxisSpacing: 0.5,
        cacheExtent: 10,
        // Start of Selection
        itemCount: movieProvider.movies.length,
        itemBuilder: (context, index) {
          final movie = movieProvider.movies[index];
          return MovieCard(movie: movie);
        });

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
