// lib/main.dart
import 'package:flutter/material.dart';
import 'package:myapp/services/tmdb_api_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app_shell.dart';
import 'package:myapp/providers/movie_provider.dart';
import 'package:myapp/providers/tv_series_provider.dart';
import 'package:myapp/providers/anime_provider.dart';
import 'package:myapp/screens/anime_grid_screen.dart';
import 'package:myapp/services/cache_service.dart';
// Import MovieProvider
import 'package:myapp/utils/colors.dart';
import 'package:media_kit/media_kit.dart'; // Import media_kit

void main() {
  // --- Initialize MediaKit ---
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  TmdbApiService();

  // --- End MediaKit Init ---

  runApp(
    MultiProvider(
      // Use MultiProvider if you have more than one
      providers: [
        ChangeNotifierProvider(
            create: (context) => MovieProvider()), // Add MovieProvider
        ChangeNotifierProvider(create: (context) => TvSeriesProvider()),
        ChangeNotifierProvider(create: (context) => AnimeProvider()),
        ChangeNotifierProvider(create: (context) => DrawerState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Load movies when the app starts
    // Do this after the first frame to ensure context is available if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadMovies();
    });

    return MaterialApp(
      title: '', // Updated title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accentColor,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.iconColor),
          titleTextStyle:
              TextStyle(color: AppColors.primaryText, fontSize: 20.0),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentColor,
          secondary: AppColors.accentColor,
          surface: AppColors.secondaryBackground,
          onPrimary: AppColors.primaryText,
          onSecondary: AppColors.primaryText,
          onSurface: AppColors.primaryText,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.iconColor),
        useMaterial3: true,
        dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.secondaryBackground), // Style dialogs
      ),
      home: const AppShell(),
    );
  }
}
