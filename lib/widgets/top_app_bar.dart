// lib/widgets/top_app_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/lists_model.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/screens/movie_details_screen.dart';
import 'package:myapp/screens/search_screen_tv.dart';
import 'package:myapp/screens/search_screen.dart'; // Navigate to SearchScreen
import 'package:myapp/utils/colors.dart';
import 'package:provider/provider.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const TopAppBar({required this.onMenuPressed, super.key});

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
      title: Row( // Keep YT logo for now or replace
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/YouTube_Logo_2017.svg/100px-YouTube_Logo_2017.svg.png',
             height: 22,
           ),
        ],
      ),
      actions: [
        IconButton(
           icon: const Icon(Icons.cast_outlined, color: AppColors.iconColor),
           onPressed: () { },
           tooltip: 'Cast',
        ),
        IconButton(
           icon: const Icon(Icons.notifications_outlined, color: AppColors.iconColor),
           onPressed: () { },
           tooltip: 'Notifications',
        ),
        // --- Updated Search Icon ---
        IconButton(
          icon: const Icon(Icons.search_outlined, color: AppColors.iconColor),
          onPressed: () {
             // Option 1: Navigate to a dedicated Search Screen
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreenTv()));
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
               backgroundColor: Colors.grey,
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
            backgroundColor: AppColors.secondaryBackground, // Darker AppBar for search
        ),
        inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: AppColors.secondaryText),
            // Use OutlineInputBorder or similar for better visibility
             border: InputBorder.none, // Keep it simple for now
             focusedBorder: InputBorder.none,
        ),
        textTheme: theme.textTheme.copyWith(
             titleLarge: const TextStyle( // Style for query text
                color: AppColors.primaryText,
                fontSize: 18.0,
             ),
        )
    );
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
     return Consumer<MovieProvider>(
       builder: (context, provider, child) {
         if (provider.movies.isEmpty) {
            return Center(child: Text('No results found for "$query"', style: const TextStyle(color: AppColors.secondaryText)));
         }
          return ListView.builder( // Or GridView
             itemCount: provider.movies.length,
             itemBuilder: (context, index) {
                final movie = provider.movies[index];
                // Use a ListTile for simplicity in search results
                return ListTile(
                   leading: movie.getPosterUrl() != null ? SizedBox(width: 50, child: CachedNetworkImage(imageUrl: movie.getPosterUrl()!, fit: BoxFit.cover)) : null,
                   title: Text(movie.title, style: const TextStyle(color: AppColors.primaryText)),
                    subtitle: Text(movie.releaseDate?.year.toString() ?? '', style: const TextStyle(color: AppColors.secondaryText)),
                   onTap: () {
                      close(context, movie as Movie?); // Close search and return selected movie
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)));
                   },
                );
             },
          );
       }
     );
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
     return Container(color: AppColors.primaryBackground); // Keep suggestions empty for now
   }
}
