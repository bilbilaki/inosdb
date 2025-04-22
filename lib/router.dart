// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app_shell.dart'; // Your AppShell wrapping widget
import 'package:myapp/screens/anime_details_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/movie_details_screen.dart';
import 'package:myapp/screens/tv_series_details_screen.dart';
import 'package:myapp/screens/tv_series_grid_screen.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/screens/genre_list_screen.dart';
import 'package:myapp/screens/library_screen.dart';
import 'package:myapp/screens/shorts_screen.dart';
import 'package:myapp/screens/favorites_screen.dart';
import 'package:myapp/screens/watchlist_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/genre_detail_screen.dart';
import 'package:myapp/screens/subscriptions_screen.dart';
import 'package:myapp/screens/downloads_screen.dart';
import 'package:myapp/services/user_data_service.dart';
import 'package:myapp/screens/video_player_screen.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/widgets/movie_card.dart';
import 'package:myapp/widgets/tv_series_card.dart';
import 'package:myapp/widgets/anime_series_card.dart';
import 'package:myapp/widgets/video_card.dart';
import 'package:myapp/widgets/custom_side_drawer.dart';
import 'package:myapp/widgets/anime_episodes_tile.dart';
import 'package:myapp/widgets/episode_tile.dart';
import 'package:myapp/screens/search_screen.dart';
import 'package:myapp/screens/search_screen_tv.dart';
import 'package:myapp/screens/search_screen_anime.dart';
import 'package:myapp/screens/unisearch_screen.dart';

// Use a GlobalKey for the ShellRoute Navigator
// This allows routing *within* the shell (like pushing details pages later)
// without replacing the shell itself.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

// Define route paths as constants for easier management
class AppRoutes {
  static const home = '/';
  static const tvSeries = '/tv';
  static const anime = '/anime';
  static const genres = '/genres';
  static const library = '/library';
  static const shorts = '/shorts'; // Route for the Shorts screen
  static const favorites = '/favorites'; // Route for the Shorts screen
  static const watchlist = '/watchlist'; // Route for the Shorts screen
  static const settings = '/settings'; // Route for the Shorts screen
  static const genreDetail = '/genre/:genre'; // Route for the Shorts screen
  static const subscriptions = '/subscriptions'; // Route for the Shorts screen
  static const downloads = '/downloads'; // Route for the Shorts screen
  static const videoPlayer = '/video/:url'; // Route for the Shorts screen
  static const animeDetail = '/anime/:id'; // Route for the Shorts screen
  static const tvSeriesDetail = '/tv/:id'; // Route for the Shorts screen
  static const movieDetail = '/movie/:id'; // Route for the Shorts screen
  static const search = '/search'; // Route for the Shorts screen
  static const searchResults = '/search/:query'; // Route for the Shorts screen
  static const searchResultsTv =
      '/search/tv/:query'; // Route for the Shorts screen
  static const searchResultsAnime =
      '/search/anime/:query'; // Route for the Shorts screen
  static const searchtv = '/searchtv';
  static const searchanime = '/searchanime';
  static const unifiedSearch = '/unifiedsearch';
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home, // Start at the home screen
  routes: [
    // ShellRoute defines the common UI structure (AppShell)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      // The builder function creates the AppShell widget.
      // The 'child' parameter is the actual screen content
      // provided by the nested GoRoutes.
      builder: (context, state, child) {
        // Pass the child widget (the screen content) to AppShell
        return AppShell(child: child);
      },
      routes: [
        // These routes are displayed within the AppShell
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.tvSeries,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TvSeriesGridScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.anime,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AnimeGridScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.genres,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GenreListScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.watchlist,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WatchlistScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.genreDetail,
          pageBuilder: (context, state) => NoTransitionPage(
            child: GenreDetailScreen(genre: state.pathParameters['genre']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.subscriptions,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SubscriptionsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.downloads,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DownloadsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.videoPlayer,
          pageBuilder: (context, state) {
            try {
              final url = Uri.decodeComponent(state.pathParameters['url']!);
              return NoTransitionPage(
                child: VideoPlayerScreen(videoUrl: url),
              );
            } catch (e) {
              return NoTransitionPage(
                child: Scaffold(
                  body: Center(
                    child: Text(
                        'Invalid video URL: ${state.pathParameters['url']}'),
                  ),
                ),
              );
            }
          },
        ),
        GoRoute(
          path: AppRoutes.animeDetail,
          pageBuilder: (context, state) {
            try {
              final id = int.parse(state.pathParameters['id']!);
              return NoTransitionPage(
                child: AnimeDetailsScreen(tvSeriesId: id),
              );
            } catch (e) {
              return NoTransitionPage(
                child: Scaffold(
                  body: Center(
                    child:
                        Text('Invalid anime ID: ${state.pathParameters['id']}'),
                  ),
                ),
              );
            }
          },
        ),
        GoRoute(
          path: AppRoutes.tvSeriesDetail,
          pageBuilder: (context, state) {
            try {
              final id = int.parse(state.pathParameters['id']!);
              return NoTransitionPage(
                child: TvSeriesDetailsScreen(tvSeriesId: id),
              );
            } catch (e) {
              return NoTransitionPage(
                child: Scaffold(
                  body: Center(
                    child: Text(
                        'Invalid TV series ID: ${state.pathParameters['id']}'),
                  ),
                ),
              );
            }
          },
        ),
        GoRoute(
          path: AppRoutes.movieDetail,
          pageBuilder: (context, state) {
            try {
              final id = int.parse(state.pathParameters['id']!);
              return NoTransitionPage(
                child: MovieDetailsScreen(movieId: id),
              );
            } catch (e) {
              return NoTransitionPage(
                child: Scaffold(
                  body: Center(
                    child:
                        Text('Invalid movie ID: ${state.pathParameters['id']}'),
                  ),
                ),
              );
            }
          },
        ),
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.searchResults,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SearchScreen(query: state.pathParameters['query']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.searchResultsTv,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SearchScreenTv(query: state.pathParameters['query']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.searchResultsAnime,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SearchScreenAnime(query: state.pathParameters['query']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.searchtv,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreenTv(),
          ),
        ),
        GoRoute(
          path: AppRoutes.searchanime,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreenAnime(),
          ),
        ),
        GoRoute(
          path: AppRoutes.unifiedSearch,
          pageBuilder: (context, state) =>  NoTransitionPage(
            child: UnifiedSearchScreen(),
          ),
        ),
      ],
    ),

    // This route is defined *outside* the ShellRoute
    // so it pushes on top of the entire AppShell.
    GoRoute(
      path: AppRoutes.shorts,
      // Use default MaterialPage transition
      builder: (context, state) => const ShortsScreen(),
    ),

    // --- Add other top-level routes here (e.g., Login, Settings) ---
    // GoRoute(path: '/login', builder: ...),

    // --- Add routes for detail pages *inside* ShellRoute or as top-level ---
    // Example: Movie Detail (could be top-level or nested in shell)
    // GoRoute(
    //   path: '/movie/:id', // Example with parameter
    //   builder: (context, state) {
    //     final movieId = state.pathParameters['id']!;
    //     return MovieDetailScreen(movieId: movieId);
    //   },
    // ),
  ],
  // Optional: Add error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);

// Use NoTransitionPage for tabs to avoid animations between them
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child, super.key})
      : super(
          transitionsBuilder: _transitionsBuilder,
          transitionDuration: Duration.zero, // No duration
          reverseTransitionDuration: Duration.zero, // No duration
        );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Just return the child directly without any transition
    return child;
  }
}
