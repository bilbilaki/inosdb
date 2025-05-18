// lib/screens/genre_list_screen.dart
import 'package:flutter/material.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:miko/screens/genre_detail_screen.dart'; // Will create this next
import 'package:miko/utils/colors.dart';
import 'package:provider/provider.dart';


class GenreListScreen extends StatelessWidget {
  const GenreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access providers to get genres
    // Use watch to rebuild if providers load/change (though unlikely after initial load)
    final movieProvider = Provider.of<MovieProvider>(context);
    final tvProvider = Provider.of<TvSeriesProvider>(context);
    final animeProvider = Provider.of<AnimeProvider>(context); // Assuming you have AnimeProvider

    // Combine genres from all sources and make unique
    final Set<String> allGenres = {};
    allGenres.addAll(movieProvider.movies.expand((m) => m.genres).where((g) => g.isNotEmpty));
    allGenres.addAll(tvProvider.seriesForDisplay.expand((s) => s.genres).where((g) => g.isNotEmpty));
    allGenres.addAll(animeProvider.animeseriesForDisplay.expand((a) => a.genres).where((g) => g.isNotEmpty)); // Adapt for Anime model

    // Convert set to sorted list
    final sortedGenres = allGenres.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));


    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      // No AppBar needed if it's part of AppShell's IndexedStack
      body: (movieProvider.isLoading || tvProvider.isLoading || animeProvider.isLoading) && sortedGenres.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor))
            : sortedGenres.isEmpty
              ? const Center(child: Text('No genres found.', style: TextStyle(color: AppColors.secondaryText)))
              : GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Or 3
                    childAspectRatio: 3 / 1, // Adjust aspect ratio for genre chips/cards
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: sortedGenres.length,
                  itemBuilder: (context, index) {
                    final genre = sortedGenres[index];
                    return InkWell(
            child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GenreDetailScreen(genre: genre)));
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          // Use a gradient or solid color for genre cards
                          gradient: LinearGradient(
                            colors: [AppColors.accentColor.withOpacity(0.5), AppColors.accentColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                         // border: Border.all(color: AppColors.accentColor.withOpacity(0.5))
                        ),
                        child: Center(
                          child: Text(
                            genre,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 2)],
                            ),
                          ),
                        ),
                      ),
                    ));
                  },
                ),
    );
  }
}