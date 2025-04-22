// lib/screens/genre_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/widgets/anime_series_card.dart'; // Assuming you have AnimeCard
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/models/tv_series_anime.dart';

import 'package:myapp/utils/colors.dart';

class GenreDetailScreen extends StatelessWidget {
  final String genre;

  const GenreDetailScreen({required this.genre, super.key});

  @override
  Widget build(BuildContext context) {
    // Get items matching the genre
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false); // If you have anime

    final List<Movie> moviesInGenre = movieProvider.movies
        .where((m) => m.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
        .toList();

    final List<TvSeries> tvSeriesInGenre = tvProvider.seriesForDisplay // Use seriesForDisplay to respect potential sorting/filtering
        .where((s) => s.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
        .toList();

    final List<TvSeriesAnime> animeInGenre = animeProvider.animeseriesForDisplay // Adjust for your Anime model/provider
        .where((a) => a.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
        .toList();

    // Combine all items
    final List<dynamic> allItemsInGenre = [...moviesInGenre, ...tvSeriesInGenre, ...animeInGenre];
    allItemsInGenre.shuffle(); // Optional: Mix movies and TV shows


    return Scaffold(
       backgroundColor: AppColors.primaryBackground,
       appBar: AppBar(
         title: Text(genre),
         backgroundColor: AppColors.secondaryBackground,
       ),
       body: allItemsInGenre.isEmpty
           ? Center(
               child: Text(
                 'No items found for the genre "$genre".',
                 style: const TextStyle(color: AppColors.secondaryText),
               ),
             )
            : MasonryGridView.count( // Use MasonryGrid for mixed content might look odd, consider separate lists or tabs
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: allItemsInGenre.length,
                itemBuilder: (context, index) {
                  final item = allItemsInGenre[index];
                   if (item is Movie) {
                     return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
            ),
            child: MovieCard(movie: item));
                   } else if (item is TvSeries) {
                     return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
            ),
            child: TvSeriesCard(series: item));
                   } else if (item is TvSeriesAnime) { // Assuming AnimeCard exists
                     return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
            ),
            child: AnimeSeriesCard(series: item)); // Adapt as needed
                   }
                   return Tilt(
            borderRadius: BorderRadius.circular(12),
            tiltConfig: const TiltConfig(
              angle: 15,
            ),
            child: const SizedBox.shrink());
                },
              ),
    );
  }
}