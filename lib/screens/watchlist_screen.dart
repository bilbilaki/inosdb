// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miko/models/movie.dart';
import 'package:miko/widgets/movie_card.dart';
import 'package:miko/widgets/anime_series_card.dart';
import 'package:miko/widgets/tv_series_card.dart';
import 'package:provider/provider.dart';
import 'package:miko/models/tv_series_anime.dart';
import 'package:miko/models/tv_series.dart';
import 'package:miko/providers/movie_provider.dart';
import 'package:miko/providers/tv_series_provider.dart';
import 'package:miko/providers/anime_provider.dart';
import 'package:miko/services/user_data_service.dart';
import 'package:miko/utils/colors.dart';

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
        title: const Text('Watchlist', style: TextStyle(color: AppColors.primaryText)),
         backgroundColor: const Color.fromARGB(255, 62, 27, 90),
      ),
      body: allWatchlist.isEmpty
          ? const Center(
              child: Text(
                'Your watchlist is empty.',
                style: TextStyle(color: Color.fromARGB(255, 234, 234, 234)),
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
return MovieCard(movie: item);
                }
                else if (item is TvSeriesAnime) {
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
