// lib/screens/genre_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/models/movie.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/widgets/anime_series_card.dart'; // Assuming you have AnimeCard
import 'package:miko/widgets/movie_card.dart';
import 'package:miko/widgets/tv_series_card.dart';
import 'package:provider/provider.dart';
//import 'package:miko/models/movie.dart' as movie;
import 'package:miko/models/tv_series_anime.dart';
import 'package:miko/models/tv_series.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';

import 'package:miko/utils/colors.dart';

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
        .where((m) => m.genres!.any((g) => g.toLowerCase() == genre.toLowerCase()))
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
         title: Text(genre, style: TextStyle(color: AppColors.primaryText)),
         backgroundColor: const Color.fromARGB(255, 62, 27, 90),
       ),
       body: allItemsInGenre.isEmpty
           ? Center(
               child: Text(
                 'No items found for the genre "$genre".',
                 style: const TextStyle(color: Color.fromARGB(255, 230, 225, 225)),
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
                     return MovieCard(movie: item);
                   } else if (item is TvSeries) {
                     return TvSeriesCard(series: item);
                   } else if (item is TvSeriesAnime) { // Assuming AnimeCard exists
                     return AnimeSeriesCard(series: item); // Adapt as needed
                   }
                   return const SizedBox.shrink(); // Should not happen
                },
              ),
    );
  }
}