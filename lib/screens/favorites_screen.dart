// TODO Implement this library.
// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:miko/models/movie.dart';
import 'package:miko/models/tv_series.dart';
import 'package:miko/models/tv_series_anime.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:miko/utils/colors.dart';
import 'package:miko/widgets/movie_card.dart'; // Reuse existing cards
import 'package:miko/widgets/tv_series_card.dart';
import 'package:miko/widgets/anime_series_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataService>(context);
    final movieProvider = Provider.of<MovieProvider>(context,
        listen: false); // don't listen if list is static
    final tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false);

    // Get favorite items
    final favoriteMovies = userData.favoriteMovieIds
        .map((id) => movieProvider.getMovieById(id))
        .whereType<Movie>() // Filter out nulls if movie not found
        .toList();
    final favoriteAnime = userData.favoriteAnimeIds
        .map((id) => animeProvider.getAnimeByTmdbId(id))
        .whereType<TvSeriesAnime>() // Filter out nulls if movie not found
        .toList();

    final favoriteTvSeries = userData.favoriteTvSeriesIds
        .map((id) => tvProvider.getTvSeriesByTmdbId(id))
        .whereType<TvSeries>() // Filter out nulls
        .toList();

    // Combine and sort (optional, e.g., alphabetically)
    final allFavorites = [
      ...favoriteMovies,
      ...favoriteTvSeries,
      ...favoriteAnime
    ];
    allFavorites.sort((a, b) {
      String nameA;
      if (a is Movie) {
        nameA = a.title;
      } else if (a is TvSeriesAnime) {
        nameA = a.name;
      } else {
        nameA = (a as TvSeries)
            .name; // Assuming Anime model has a 'title' or 'name' field
      }

      String nameB;
      if (b is Movie) {
        nameB = b.title;
      } else if (b is TvSeriesAnime) {
        nameB = b.name;
      } else {
        nameB = (b as TvSeries)
            .name; // Assuming Anime model has a 'title' or 'name' field
      }

      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          title: const Text('Favorites', style: TextStyle(color: AppColors.primaryText)),
          backgroundColor: const Color.fromARGB(255, 62, 27, 90),
        ),
        body: allFavorites.isEmpty
            ? const Center(
                child: Text(
                  'No items added to favorites yet.',
                  style: TextStyle(color: Color.fromARGB(255, 230, 225, 225)),
                ),
              )
            : MasonryGridView.count(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 3, // Adjust columns as needed
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: allFavorites.length,
                itemBuilder: (context, index) {
                  final item = allFavorites[index];
                  if (item is Movie) {
                    return MovieCard(movie: item);
                  } else if (item is TvSeriesAnime) {
                    return AnimeSeriesCard(series: item);
                  } else if (item is TvSeries) {
                    return TvSeriesCard(series: item);
                  }
                  return const SizedBox.shrink(); // Should not happen
                },
              ),
    );
  }
}
