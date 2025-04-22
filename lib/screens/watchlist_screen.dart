// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:myapp/widgets/anime_series_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/tv_series_anime.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/services/user_data_service.dart';
import 'package:myapp/utils/colors.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

 @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataService>(context);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);
    final animeProvider = Provider.of<AnimeProvider>(context, listen: false);
    final watchlistMovies = userData.watchlistMovieIds
        .map((id) => movieProvider.getMovieById(id))
        .whereType<Movie>()
        .toList();

    final watchlistTvSeries = userData.watchlistTvSeriesIds
        .map((id) => tvProvider.getTvSeriesByTmdbId(id))
        .whereType<TvSeries>()
        .toList();

       final watchlistAnime = userData.watchlistAnimeIds
        .map((id) => animeProvider.getAnimeByTmdbId(id))
        .whereType<TvSeriesAnime>() // Filter out nulls if movie not found
        .toList();

    final allWatchlist = [...watchlistMovies, ...watchlistTvSeries, ...watchlistAnime];
     allWatchlist.sort((a, b) { // Optional sort
    String nameA;
    if (a is Movie) {
      nameA = a.title;
    } else if (a is TvSeries) {
      nameA = a.name;
    } else {
      nameA = (a as TvSeriesAnime).name; // Assuming Anime model has a 'title' or 'name' field
    }

    String nameB;
    if (b is Movie) {
      nameB = b.title;
    } else if (b is TvSeries) {
      nameB = b.name;
    } else {
      nameB = (b as TvSeriesAnime).name; // Assuming Anime model has a 'title' or 'name' field
    }
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Watchlist'),
         backgroundColor: AppColors.secondaryBackground,
      ),
      body: allWatchlist.isEmpty
          ? const Center(
              child: Text(
                'Your watchlist is empty.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(8.0),
              crossAxisCount: 3, // Adjust columns as needed
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              itemCount: allWatchlist.length,
              itemBuilder: (context, index) {
                final item = allWatchlist[index];
                if (item is Movie) {
                  return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: MovieCard(movie: item));
                }
                else if (item is TvSeriesAnime) {
                  return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: AnimeSeriesCard(series: item));
                } else if (item is TvSeries) {
                  return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: TvSeriesCard(series: item));
                }
                return Tilt(
          borderRadius: BorderRadius.circular(12),
          tiltConfig: const TiltConfig(
            angle: 15,
          ),
          child: const SizedBox.shrink()); // Should not happen
              },
            ),
    );
  }
}
