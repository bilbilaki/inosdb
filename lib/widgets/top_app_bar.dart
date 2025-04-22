// lib/widgets/top_app_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/lists_model.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/screens/movie_details_screen.dart';
import 'package:myapp/screens/search_screen_anime.dart';
import 'package:myapp/screens/search_screen_tv.dart';
import 'package:myapp/screens/search_screen.dart'; // Navigate to SearchScreen
import 'package:myapp/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/tv_series.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/screens/tv_series_details_screen.dart';
import 'package:myapp/router.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/models/tv_series_anime.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/models/season_anime.dart';
import 'package:myapp/screens/unisearch_screen.dart';
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final int selectedIndex;
  const TopAppBar(
      {required this.onMenuPressed, required this.selectedIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // ... (previous AppBar setup: leading, title, other actions) ...
      elevation: 0,
      backgroundColor: AppColors.primaryBackground,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.iconColor),
        onPressed: onMenuPressed,
        tooltip: 'Open navigation menu',
      ),
      titleSpacing: 0,
      title: Row(
        // Keep YT logo for now or replace
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/YouTube.png',
            height: 22,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cast_outlined, color: AppColors.iconColor),
          onPressed: () {},
          tooltip: 'Cast',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.iconColor),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        // --- Updated Search Icon ---
        IconButton(
          icon: const Icon(Icons.search_outlined, color: AppColors.iconColor),
          onPressed: () {
            context.go('/unifiedsearch');
              // Option 2: Show Search Delegate (more integrated)
              // showSearch(context: context, delegate: MovieSearchDelegate());
          },
          tooltip: 'Search Movies',
        ),
        // --- End Search Icon ---
        const Padding(
          padding: EdgeInsets.only(right: 12.0, left: 6.0),
          child: CircleAvatar(
            radius: 15.0,
            backgroundImage: AssetImage('assets/1.jpg'), // Placeholder avatar
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --- Optional: Search Delegate (More integrated search UI) ---

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor:
              AppColors.secondaryBackground, // Darker AppBar for search
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          // Use OutlineInputBorder or similar for better visibility
          border: InputBorder.none, // Keep it simple for now
          focusedBorder: InputBorder.none,
        ),
        textTheme: theme.textTheme.copyWith(
          titleLarge: const TextStyle(
            // Style for query text
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 18.0,
          ),
        ));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppColors.iconColor),
        onPressed: () {
          query = ''; // Clear the search query
          showSuggestions(context); // Refresh suggestions
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
      onPressed: () {
        close(context, null); // Close search, return null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Trigger search in provider when user submits (Enter key)
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.searchMovies(query);

    // Display results using a ListView/GridView similar to HomeScreen
    return Consumer<MovieProvider>(builder: (context, provider, child) {
      if (provider.movies.isEmpty) {
        return Center(
            child: Text('No results found for "$query"',
                style: const TextStyle(color: AppColors.secondaryText)));
      }
      return ListView.builder(
        // Or GridView
        itemCount: provider.movies.length,
        itemBuilder: (context, index) {
          final movie = provider.movies[index];
          // Use a ListTile for simplicity in search results
          return ListTile(
            leading: movie.getPosterUrl() != null
                ? SizedBox(
                    width: 50,
                    child: CachedNetworkImage(
                        imageUrl: movie.getPosterUrl()!, fit: BoxFit.cover))
                : null,
            title: Text(movie.title,
                style: const TextStyle(color: AppColors.primaryText)),
            subtitle: Text(movie.releaseDate?.year.toString() ?? '',
                style: const TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              close(context,
                  movie as Movie?); // Close search and return selected movie
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MovieDetailsScreen(movieId: movie.id)));
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions dynamically as user types (optional, can be simpler)
    // For simplicity, just show recent searches or nothing until submitted.
    // Or, perform search dynamically here as well.
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    // Debounce this if performing search live on suggestions
    movieProvider.searchMovies(query);
    // return Consumer<MovieProvider>(... build results list based on current query ...);
    return Container(
        color: AppColors.primaryBackground); // Keep suggestions empty for now
  }
}

class TvSeriesSearchDelegate extends SearchDelegate<TvSeries?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor:
              AppColors.secondaryBackground, // Darker AppBar for search
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        textTheme: theme.textTheme.copyWith(
          titleLarge: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 18.0,
          ),
        ));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppColors.iconColor),
        onPressed: () {
          query = ''; // Clear the search query
          showSuggestions(context); // Refresh suggestions
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
      onPressed: () {
        close(context, null); // Close search, return null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Trigger search in provider when user submits (Enter key)
    final tvSeriesProvider =
        Provider.of<TvSeriesProvider>(context, listen: false);
    tvSeriesProvider.searchTvSeries(query);

    // Display results using a ListView/GridView similar to HomeScreen
    return Consumer<TvSeriesProvider>(builder: (context, provider, child) {
      if (provider.seriesForDisplay.isEmpty) {
        return Center(
            child: Text('No results found for "$query"',
                style: const TextStyle(color: AppColors.secondaryText)));
      }
      return ListView.builder(
        itemCount: provider.seriesForDisplay.length,
        itemBuilder: (context, index) {
          final series = provider.seriesForDisplay[index];
          return ListTile(
            leading: series.fullPosterUrl != null
                ? SizedBox(
                    width: 50,
                    child: CachedNetworkImage(
                        imageUrl: series.fullPosterUrl!, fit: BoxFit.cover))
                : null,
            title: Text(series.name,
                style: const TextStyle(color: AppColors.primaryText)),
            subtitle: Text(series.firstAirDate?.toString() ?? '',
                style: const TextStyle(color: AppColors.secondaryText)),
            onTap: () {
              close(context, series); // Close search and return selected series
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          TvSeriesDetailsScreen(tvSeriesId: series.tmdbId)));
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions dynamically as user types
    final tvSeriesProvider =
        Provider.of<TvSeriesProvider>(context, listen: false);
    tvSeriesProvider.searchTvSeries(query);
    return Container(
        color: AppColors.primaryBackground); // Keep suggestions empty for now
  }
}
