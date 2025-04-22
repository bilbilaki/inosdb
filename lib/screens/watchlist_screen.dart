// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/services/user_data_service.dart';
import 'package:myapp/utils/colors.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

 @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataService>(context);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TvSeriesProvider>(context, listen: false);

    final watchlistMovies = userData.watchlistMovieIds
        .map((id) => movieProvider.getMovieById(id))
        .whereType<Movie>()
        .toList();

    final watchlistTvSeries = userData.watchlistTvSeriesIds
        .map((id) => tvProvider.getTvSeriesByTmdbId(id))
        .whereType<TvSeries>()
        .toList();

    final allWatchlist = [...watchlistMovies, ...watchlistTvSeries];
     allWatchlist.sort((a, b) { // Optional sort
      String nameA = a is Movie ? a.title : (a as TvSeries).name;
      String nameB = b is Movie ? b.title : (b as TvSeries).name;
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
          : MasonryGridView.count( // Or ListView
              padding: const EdgeInsets.all(8.0),
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              itemCount: allWatchlist.length,
              itemBuilder: (context, index) {
                final item = allWatchlist[index];
                if (item is Movie) {
                  return MovieCard(movie: item);
                } else if (item is TvSeries) {
                  return TvSeriesCard(series: item);
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }
}