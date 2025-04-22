// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app_shell.dart'; // Your AppShell wrapping widget
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/tv_series_grid_screen.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/screens/genre_list_screen.dart';
import 'package:myapp/screens/library_screen.dart';
import 'package:myapp/screens/shorts_screen.dart';
import 'package:myapp/screens/favorites_screen.dart';
import 'package:myapp/screens/watchlist_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
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
